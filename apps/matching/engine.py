"""
BaaraLink – Matching Engine
Algorithme de scoring pour recommander les meilleurs prestataires.

Score = (rating_score × 0.40) + (proximity_score × 0.30)
      + (completion_score × 0.15) + (availability_score × 0.15)
"""
import math
import logging
from typing import Optional
from apps.profiles.models import Profile

logger = logging.getLogger('apps.matching')


def haversine_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    R = 6371
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = (math.sin(dlat/2)**2 +
         math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon/2)**2)
    return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))


class MatchingEngine:

    MAX_DISTANCE_KM = 50
    TOP_N           = 5

    @classmethod
    def get_recommendations(
        cls,
        category_id: Optional[str] = None,
        city: Optional[str] = None,
        lat: Optional[float] = None,
        lng: Optional[float] = None,
        budget_max: Optional[int] = None,
        top_n: int = None,
    ) -> list:
        """
        Retourne les top N prestataires scorés pour un besoin donné.
        """
        top_n = top_n or cls.TOP_N
        qs = Profile.objects.select_related('user').prefetch_related('categories').filter(
            user__is_active=True,
            user__role='provider',
            user__phone_verified=True,
            availability=Profile.AvailabilityStatus.AVAILABLE,
        )

        # Filtre catégorie
        if category_id:
            qs = qs.filter(categories__id=category_id)

        # Filtre ville (fallback si pas de coords GPS)
        if city and not lat:
            qs = qs.filter(city__icontains=city)

        # Filtre budget
        if budget_max:
            qs = qs.filter(hourly_rate__lte=budget_max)

        scored = []
        for profile in qs:
            score_data = cls._score(profile, lat, lng)
            scored.append((profile, score_data))

        # Tri par score total décroissant
        scored.sort(key=lambda x: x[1]['total_score'], reverse=True)

        results = []
        for profile, score_data in scored[:top_n]:
            profile._distance_km = score_data.get('distance_km')
            profile._match_score = score_data['total_score']
            results.append(profile)

        return results

    @classmethod
    def _score(cls, profile: Profile, lat: Optional[float], lng: Optional[float]) -> dict:
        # 1. Rating score (0–1)
        rating_score = float(profile.avg_rating) / 5.0

        # 2. Proximity score (0–1)
        distance_km = None
        if lat and lng and profile.latitude and profile.longitude:
            distance_km = haversine_km(
                lat, lng,
                float(profile.latitude), float(profile.longitude)
            )
            if distance_km > cls.MAX_DISTANCE_KM:
                proximity_score = 0
            else:
                proximity_score = 1 - (distance_km / cls.MAX_DISTANCE_KM)
        else:
            proximity_score = 0.5  # Pas de coords → score neutre

        # 3. Profile completion (0–1)
        completion_score = profile.completion_score / 100.0

        # 4. Availability bonus
        availability_score = 1.0 if profile.availability == Profile.AvailabilityStatus.AVAILABLE else 0.3

        # 5. Trust bonus
        trust_bonus = 0.0
        if profile.is_certified: trust_bonus += 0.1
        if profile.is_verified:  trust_bonus += 0.05

        total = (
            rating_score      * 0.40 +
            proximity_score   * 0.30 +
            completion_score  * 0.15 +
            availability_score * 0.15 +
            trust_bonus
        )

        return {
            'total_score':       round(min(total, 1.0), 4),
            'rating_score':      round(rating_score, 4),
            'proximity_score':   round(proximity_score, 4),
            'completion_score':  round(completion_score, 4),
            'availability_score':round(availability_score, 4),
            'distance_km':       round(distance_km, 1) if distance_km else None,
        }
