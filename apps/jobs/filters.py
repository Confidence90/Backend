"""BaaraLink – Jobs Filters"""
import django_filters
from .models import Job


class JobFilter(django_filters.FilterSet):
    city        = django_filters.CharFilter(field_name='city',     lookup_expr='icontains')
    district    = django_filters.CharFilter(field_name='district', lookup_expr='icontains')
    category    = django_filters.UUIDFilter(field_name='category__id')
    job_type    = django_filters.ChoiceFilter(choices=Job.JobType.choices)
    status      = django_filters.ChoiceFilter(choices=Job.Status.choices)
    urgency     = django_filters.ChoiceFilter(choices=Job.UrgencyLevel.choices)
    budget_min  = django_filters.NumberFilter(field_name='budget_min', lookup_expr='gte')
    budget_max  = django_filters.NumberFilter(field_name='budget_max', lookup_expr='lte')
    created_after  = django_filters.DateTimeFilter(field_name='created_at', lookup_expr='gte')
    created_before = django_filters.DateTimeFilter(field_name='created_at', lookup_expr='lte')

    class Meta:
        model  = Job
        fields = ['city', 'district', 'category', 'job_type', 'status', 'urgency']
