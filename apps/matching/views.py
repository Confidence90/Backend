"""BaaraLink – Matching API"""
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from drf_spectacular.utils import extend_schema, OpenApiParameter
from apps.profiles.serializers import ProfileListSerializer
from .engine import MatchingEngine


class RecommendationsView(APIView):
    """
    GET /matching/recommendations/
    Params: category, city, lat, lng, budget_max, top_n (max 10)
    """
    permission_classes = [IsAuthenticated]

    @extend_schema(parameters=[
        OpenApiParameter('category', str, description='UUID catégorie'),
        OpenApiParameter('city',     str, description='Ville (ex: Bamako)'),
        OpenApiParameter('lat',      float, description='Latitude GPS'),
        OpenApiParameter('lng',      float, description='Longitude GPS'),
        OpenApiParameter('budget_max', int, description='Budget max en FCFA'),
        OpenApiParameter('top_n',    int,  description='Nombre de résultats (max 10)'),
    ])
    def get(self, request):
        p = request.query_params
        try:
            lat = float(p.get('lat')) if p.get('lat') else None
            lng = float(p.get('lng')) if p.get('lng') else None
        except ValueError:
            lat = lng = None

        top_n = min(int(p.get('top_n', 5)), 10)

        profiles = MatchingEngine.get_recommendations(
            category_id=p.get('category'),
            city=p.get('city'),
            lat=lat,
            lng=lng,
            budget_max=int(p.get('budget_max')) if p.get('budget_max') else None,
            top_n=top_n,
        )

        data = ProfileListSerializer(profiles, many=True, context={'request': request}).data

        # Enrichit avec le score de matching
        for i, profile in enumerate(profiles):
            if i < len(data):
                data[i]['match_score'] = getattr(profile, '_match_score', None)

        return Response({
            'count': len(data),
            'results': data,
        })
