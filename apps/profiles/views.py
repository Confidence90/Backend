"""BaaraLink – Profiles Views"""
import math
from rest_framework import viewsets, generics, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser

from .models import Profile, Category, PortfolioItem
from .serializers import (
    ProfileListSerializer, ProfileDetailSerializer,
    ProfileUpdateSerializer, CategorySerializer, PortfolioItemSerializer
)
from .filters import ProfileFilter


def haversine_km(lat1, lon1, lat2, lon2):
    """Distance approximative entre deux points GPS (km)."""
    R = 6371
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = (math.sin(dlat/2)**2 +
         math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon/2)**2)
    return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))


class ProfileViewSet(viewsets.ReadOnlyModelViewSet):
    """
    GET /profiles/           → liste des prestataires (filtrée)
    GET /profiles/{id}/      → détail prestataire
    GET /profiles/me/        → mon profil
    PATCH /profiles/me/      → modifier mon profil
    POST /profiles/me/portfolio/  → ajouter une photo portfolio
    """
    filterset_class = ProfileFilter
    search_fields   = ['bio', 'city', 'district', 'user__first_name', 'user__last_name']
    ordering_fields = ['avg_rating', 'completed_missions', 'hourly_rate']
    ordering        = ['-avg_rating', '-completed_missions']

    def get_queryset(self):
        qs = Profile.objects.select_related('user').prefetch_related(
            'categories', 'skills', 'portfolio'
        ).filter(user__is_active=True, user__role='provider')

        # Géolocalisation simple
        lat = self.request.query_params.get('lat')
        lng = self.request.query_params.get('lng')
        radius = float(self.request.query_params.get('radius_km', 50))

        if lat and lng:
            try:
                lat, lng = float(lat), float(lng)
                result = []
                for profile in qs:
                    if profile.latitude and profile.longitude:
                        d = haversine_km(lat, lng, float(profile.latitude), float(profile.longitude))
                        if d <= radius:
                            profile._distance_km = round(d, 1)
                            result.append(profile)
                result.sort(key=lambda p: getattr(p, '_distance_km', 9999))
                return result
            except (ValueError, TypeError):
                pass
        return qs

    def get_serializer_class(self):
        if self.action == 'retrieve':
            return ProfileDetailSerializer
        return ProfileListSerializer

    def get_permissions(self):
        if self.action in ('me', 'update_me', 'add_portfolio'):
            return [IsAuthenticated()]
        return [AllowAny()]

    @action(detail=False, methods=['get', 'patch'], url_path='me')
    def me(self, request):
        profile, _ = Profile.objects.get_or_create(user=request.user)
        if request.method == 'PATCH':
            serializer = ProfileUpdateSerializer(
                profile, data=request.data, partial=True,
                context={'request': request}
            )
            serializer.is_valid(raise_exception=True)
            serializer.save()
            return Response(ProfileDetailSerializer(profile, context={'request': request}).data)
        return Response(ProfileDetailSerializer(profile, context={'request': request}).data)

    @action(
        detail=False, methods=['post'], url_path='me/portfolio',
        parser_classes=[MultiPartParser, FormParser]
    )
    def add_portfolio(self, request):
        profile = Profile.objects.get(user=request.user)
        serializer = PortfolioItemSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        item = serializer.save(profile=profile)
        return Response(PortfolioItemSerializer(item).data, status=status.HTTP_201_CREATED)


class CategoryListView(generics.ListAPIView):
    """GET /profiles/categories/ → toutes les catégories avec skills."""
    queryset           = Category.objects.filter(is_active=True).prefetch_related('skills')
    serializer_class   = CategorySerializer
    permission_classes = [AllowAny]
    pagination_class   = None  # Retourne tout d'un coup (peu de données)
