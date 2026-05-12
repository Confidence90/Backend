from rest_framework import mixins, viewsets, status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import Review
from .serializers import ReviewSerializer

class ReviewViewSet(mixins.CreateModelMixin, mixins.ListModelMixin,
                    mixins.RetrieveModelMixin, viewsets.GenericViewSet):
    serializer_class   = ReviewSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        qs = Review.objects.select_related('reviewer', 'reviewee', 'job').filter(is_active=True)
        reviewee = self.request.query_params.get('reviewee')
        job      = self.request.query_params.get('job')
        if reviewee: qs = qs.filter(reviewee=reviewee)
        if job:      qs = qs.filter(job=job)
        return qs
