"""BaaraLink – Users Views (Auth by phone + OTP)"""
import logging
from django.contrib.auth import get_user_model
from django.utils import timezone
from rest_framework import status, generics
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.throttling import ScopedRateThrottle
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.exceptions import TokenError
from drf_spectacular.utils import extend_schema, OpenApiParameter

from .models import OTPVerification
from .serializers import (
    RegisterSerializer, VerifyOTPSerializer, LoginRequestSerializer,
    TokenPairSerializer, UserSerializer, UpdateFCMTokenSerializer
)
from .services import SMSService

logger = logging.getLogger('apps.users')
User = get_user_model()


class RegisterRequestView(APIView):
    """
    POST /api/v1/auth/register/
    Étape 1 : reçoit les infos de base → stocke temporairement → envoie OTP.
    """
    permission_classes = [AllowAny]
    throttle_classes   = [ScopedRateThrottle]
    throttle_scope     = 'otp'

    @extend_schema(request=RegisterSerializer, responses={200: {'type': 'object'}})
    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        # Stocke les données d'inscription en cache (10 min)
        from django.core.cache import cache
        cache_key = f"register:{data['phone_number']}"
        cache.set(cache_key, {
            'first_name': data['first_name'],
            'last_name':  data['last_name'],
            'role':       data['role'],
        }, timeout=600)

        # Génère et envoie OTP
        otp = OTPVerification.create_for_phone(
            data['phone_number'],
            purpose=OTPVerification.Purpose.REGISTER
        )
        SMSService.send_otp(data['phone_number'], otp.code)

        logger.info(f"Register OTP sent to {data['phone_number']}")
        return Response({'message': 'Code OTP envoyé.', 'phone': data['phone_number']})


class RegisterVerifyView(APIView):
    """
    POST /api/v1/auth/register/verify/
    Étape 2 : vérifie OTP → crée le compte → retourne JWT.
    """
    permission_classes = [AllowAny]

    @extend_schema(request=VerifyOTPSerializer, responses={201: TokenPairSerializer})
    def post(self, request):
        serializer = VerifyOTPSerializer(
            data={**request.data, 'purpose': OTPVerification.Purpose.REGISTER}
        )
        serializer.is_valid(raise_exception=True)
        data       = serializer.validated_data
        phone      = data['phone_number']
        otp        = data['otp']

        from django.core.cache import cache
        reg_data = cache.get(f"register:{phone}")
        if not reg_data:
            return Response(
                {'error': 'Session expirée. Recommencez l\'inscription.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Crée l'utilisateur
        user = User.objects.create_user(
            phone_number=phone,
            first_name=reg_data['first_name'],
            last_name=reg_data['last_name'],
            role=reg_data['role'],
            phone_verified=True,
        )

        # Crée le profil automatiquement (via signal)
        otp.mark_used()
        cache.delete(f"register:{phone}")

        logger.info(f"New user created: {user.id} ({phone})")
        return Response(TokenPairSerializer.from_user(user), status=status.HTTP_201_CREATED)


class LoginRequestView(APIView):
    """
    POST /api/v1/auth/login/
    Connexion par téléphone → envoi OTP.
    """
    permission_classes = [AllowAny]
    throttle_classes   = [ScopedRateThrottle]
    throttle_scope     = 'otp'

    def post(self, request):
        serializer = LoginRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        phone = serializer.validated_data['phone_number']

        otp = OTPVerification.create_for_phone(phone, purpose=OTPVerification.Purpose.LOGIN)
        SMSService.send_otp(phone, otp.code)

        return Response({'message': 'Code OTP envoyé.', 'phone': phone})


class LoginVerifyView(APIView):
    """
    POST /api/v1/auth/login/verify/
    Vérifie OTP → retourne tokens JWT.
    """
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = VerifyOTPSerializer(
            data={**request.data, 'purpose': OTPVerification.Purpose.LOGIN}
        )
        serializer.is_valid(raise_exception=True)
        data  = serializer.validated_data
        phone = data['phone_number']
        otp   = data['otp']

        user = User.objects.filter(phone_number=phone, is_active=True).first()
        if not user:
            return Response({'error': 'Compte introuvable.'}, status=status.HTTP_404_NOT_FOUND)

        otp.mark_used()
        user.last_seen = timezone.now()
        user.save(update_fields=['last_seen'])

        return Response(TokenPairSerializer.from_user(user))


class LogoutView(APIView):
    """
    POST /api/v1/auth/logout/
    Blackliste le refresh token.
    """
    permission_classes = [IsAuthenticated]

    def post(self, request):
        refresh_token = request.data.get('refresh')
        if not refresh_token:
            return Response({'error': 'Token manquant.'}, status=status.HTTP_400_BAD_REQUEST)
        try:
            token = RefreshToken(refresh_token)
            token.blacklist()
        except TokenError:
            pass
        return Response({'message': 'Déconnexion réussie.'})


class MeView(generics.RetrieveUpdateAPIView):
    """
    GET /api/v1/auth/me/      → profil courant
    PATCH /api/v1/auth/me/    → mise à jour
    """
    serializer_class   = UserSerializer
    permission_classes = [IsAuthenticated]

    def get_object(self):
        return self.request.user


class UpdateFCMTokenView(APIView):
    """
    PATCH /api/v1/auth/fcm-token/
    Met à jour le token Firebase pour les notifications push.
    """
    permission_classes = [IsAuthenticated]

    def patch(self, request):
        serializer = UpdateFCMTokenSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.update(request.user, serializer.validated_data)
        return Response({'message': 'Token FCM mis à jour.'})
