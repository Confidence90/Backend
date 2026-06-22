"""BaaraLink – Users Serializers"""
from django.utils import timezone
from rest_framework import serializers
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import get_user_model
from .models import OTPVerification

User = get_user_model()


class UserLiteSerializer(serializers.ModelSerializer):
    """Sérialiseur léger pour les listes (performance)."""
    full_name = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = ['id', 'phone_number', 'full_name', 'role', 'phone_verified']
        read_only_fields = fields

    def get_full_name(self, obj):
        return obj.get_full_name()


class UserSerializer(serializers.ModelSerializer):
    full_name = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = [
            'id', 'phone_number', 'email', 'first_name', 'last_name',
            'full_name', 'role', 'is_active', 'phone_verified',
            'date_joined', 'last_seen', 'language', 'fcm_token',
        ]
        read_only_fields = ['id', 'date_joined', 'last_seen', 'phone_verified']
        extra_kwargs = {
            'phone_number': {'required': True},
            'first_name': {'required': True},
            'last_name': {'required': True},
        }

    def get_full_name(self, obj):
        return obj.get_full_name()


class RegisterSerializer(serializers.Serializer):
    """Étape 1 : demande d'inscription → envoi OTP."""
    phone_number = serializers.CharField(max_length=20)
    first_name   = serializers.CharField(max_length=80)
    last_name    = serializers.CharField(max_length=80)
    role         = serializers.ChoiceField(choices=User.Role.choices, default=User.Role.CLIENT)

    def validate_phone_number(self, value):
        # Normalise le format +223XXXXXXXX
        value = value.strip().replace(' ', '')
        if not value.startswith('+'):
            value = '+223' + value
        if User.objects.filter(phone_number=value).exists():
            raise serializers.ValidationError("Ce numéro est déjà enregistré.")
        return value


class VerifyOTPSerializer(serializers.Serializer):
    """Étape 2 : vérification OTP → création compte + tokens JWT."""
    phone_number = serializers.CharField(max_length=20)
    code         = serializers.CharField(max_length=6, min_length=6)
    purpose      = serializers.ChoiceField(
        choices=OTPVerification.Purpose.choices,
        default=OTPVerification.Purpose.REGISTER
    )

    def validate(self, attrs):
        phone = attrs['phone_number']
        code  = attrs['code']
        purpose = attrs.get('purpose', OTPVerification.Purpose.REGISTER)

        otp = OTPVerification.objects.filter(
            phone_number=phone,
            purpose=purpose,
            is_used=False
        ).order_by('-created_at').first()

        if not otp:
            raise serializers.ValidationError("Aucun OTP actif pour ce numéro.")

        otp.increment_attempts()

        if otp.expires_at <= timezone.now():
            raise serializers.ValidationError("Code expiré, demande un nouveau code.")

        if otp.attempts >= 5:
            raise serializers.ValidationError("Trop de tentatives, demande un nouveau code.")

        if otp.code != code:
            raise serializers.ValidationError("Code incorrect.")

        attrs['otp'] = otp
        return attrs


class LoginRequestSerializer(serializers.Serializer):
    """Connexion : demande OTP pour un numéro existant."""
    phone_number = serializers.CharField(max_length=20)

    def validate_phone_number(self, value):
        value = value.strip().replace(' ', '')
        if not value.startswith('+'):
            value = '+223' + value
        if not User.objects.filter(phone_number=value, is_active=True).exists():
            raise serializers.ValidationError("Compte introuvable pour ce numéro.")
        return value


class TokenPairSerializer(serializers.Serializer):
    """Réponse JWT après authentification réussie."""
    access  = serializers.CharField(read_only=True)
    refresh = serializers.CharField(read_only=True)
    user    = UserSerializer(read_only=True)

    @classmethod
    def from_user(cls, user):
        refresh = RefreshToken.for_user(user)
        return {
            'access': str(refresh.access_token),
            'refresh': str(refresh),
            'user': UserSerializer(user).data,
        }


class UpdateFCMTokenSerializer(serializers.Serializer):
    """Mise à jour du token Firebase pour les push notifications."""
    fcm_token = serializers.CharField()

    def update(self, instance, validated_data):
        instance.fcm_token = validated_data['fcm_token']
        instance.save(update_fields=['fcm_token'])
        return instance
