"""BaaraLink – Profiles Filters"""
import django_filters
from .models import Profile


class ProfileFilter(django_filters.FilterSet):
    city            = django_filters.CharFilter(lookup_expr='icontains')
    district        = django_filters.CharFilter(lookup_expr='icontains')
    category        = django_filters.UUIDFilter(field_name='categories__id')
    availability    = django_filters.ChoiceFilter(choices=Profile.AvailabilityStatus.choices)
    min_rating      = django_filters.NumberFilter(field_name='avg_rating',   lookup_expr='gte')
    max_hourly_rate = django_filters.NumberFilter(field_name='hourly_rate',  lookup_expr='lte')
    min_hourly_rate = django_filters.NumberFilter(field_name='hourly_rate',  lookup_expr='gte')
    is_verified     = django_filters.BooleanFilter()
    is_certified    = django_filters.BooleanFilter()
    experience_level = django_filters.ChoiceFilter(choices=Profile.ExperienceLevel.choices)

    class Meta:
        model  = Profile
        fields = ['city', 'category', 'availability', 'is_verified', 'is_certified']
