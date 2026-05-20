"""BaaraLink – Jobs & Applications Views"""
import logging
from django.utils import timezone
from django.db import transaction
from rest_framework import viewsets, status, generics
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, IsAuthenticatedOrReadOnly
from drf_spectacular.utils import extend_schema, OpenApiParameter

from .models import Job, Application
from .serializers import (
    JobListSerializer, JobDetailSerializer,
    JobCreateSerializer, ApplicationCreateSerializer,
    ApplicationLiteSerializer,
)
from .filters import JobFilter
from .permissions import IsClient, IsOwnerOrReadOnly, IsJobClient, IsProvider
from apps.notifications.tasks import send_notification_task

logger = logging.getLogger('apps.jobs')


class JobViewSet(viewsets.ModelViewSet):
    """
    CRUD complet pour les missions.

    list   GET    /jobs/
    create POST   /jobs/
    retrieve GET  /jobs/{id}/
    update PATCH  /jobs/{id}/
    destroy DEL   /jobs/{id}/

    Extra actions:
    apply         POST  /jobs/{id}/apply/
    accept_application PATCH /jobs/{id}/applications/{app_id}/accept/
    reject_application PATCH /jobs/{id}/applications/{app_id}/reject/
    complete      PATCH /jobs/{id}/complete/
    cancel        PATCH /jobs/{id}/cancel/
    my_jobs       GET   /jobs/my_jobs/
    """
    filterset_class = JobFilter
    search_fields   = ['title', 'description', 'city', 'district']
    ordering_fields = ['created_at', 'budget_min', 'budget_max']
    ordering        = ['-created_at']

    def get_queryset(self):
        return Job.objects.select_related(
            'client', 'assigned_to', 'category'
        ).prefetch_related('applications').filter(is_flagged=False)

    def get_serializer_class(self):
        if self.action == 'create':
            return JobCreateSerializer
        if self.action in ('list', 'my_jobs'):
            return JobListSerializer
        return JobDetailSerializer

    def get_permissions(self):
        if self.action == 'create':
            return [IsAuthenticated(), IsClient()]
        if self.action in ('update', 'partial_update', 'destroy',
                           'accept_application', 'reject_application',
                           'complete', 'cancel'):
            return [IsAuthenticated(), IsJobClient()]
        if self.action == 'apply':
            return [IsAuthenticated(), IsProvider()]
        return [IsAuthenticatedOrReadOnly()]

    @action(detail=False, methods=['get'], url_path='my-jobs')
    def my_jobs(self, request):
        """Retourne les missions du client connecté (toutes les statuts)."""
        qs = self.get_queryset().filter(client=request.user)
        page = self.paginate_queryset(qs)
        if page is not None:
            return self.get_paginated_response(
                JobListSerializer(page, many=True, context={'request': request}).data
            )
        return Response(JobListSerializer(qs, many=True, context={'request': request}).data)

    @action(detail=False, methods=['get'], url_path='assigned')
    def assigned_to_me(self, request):
        """Missions assignées au prestataire connecté."""
        qs = self.get_queryset().filter(assigned_to=request.user)
        page = self.paginate_queryset(qs)
        serializer = JobListSerializer(
            page or qs, many=True, context={'request': request}
        )
        if page is not None:
            return self.get_paginated_response(serializer.data)
        return Response(serializer.data)

    @action(detail=True, methods=['post'])
    def apply(self, request, pk=None):
        """POST /jobs/{id}/apply/ — Postuler à une mission."""
        job = self.get_object()
        serializer = ApplicationCreateSerializer(
            data=request.data,
            context={'request': request, 'job': job}
        )
        serializer.is_valid(raise_exception=True)
        application = serializer.save()

        # Notifie le client
        send_notification_task.delay(
            recipient_id=str(job.client.id),
            notif_type='new_application',
            title='Nouvelle candidature',
            body=f"{request.user.get_full_name()} a postulé à : {job.title}",
            data={'job_id': str(job.id), 'application_id': str(application.id)}
        )

        logger.info(f"Application {application.id} created for job {job.id}")
        return Response(
            ApplicationLiteSerializer(application).data,
            status=status.HTTP_201_CREATED
        )

    @action(
        detail=True, methods=['patch'],
        url_path=r'applications/(?P<app_id>[^/.]+)/accept'
    )
    def accept_application(self, request, pk=None, app_id=None):
        """Accepter une candidature → assigne le prestataire."""
        job = self.get_object()
        if job.status != Job.Status.OPEN:
            return Response(
                {'error': 'Cette mission n\'est plus ouverte.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        try:
            application = job.applications.get(id=app_id, status=Application.Status.PENDING)
        except Application.DoesNotExist:
            return Response({'error': 'Candidature introuvable.'}, status=status.HTTP_404_NOT_FOUND)

        with transaction.atomic():
            # Accepte cette candidature
            application.status = Application.Status.ACCEPTED
            application.save(update_fields=['status', 'updated_at'])

            # Refuse toutes les autres
            job.applications.exclude(id=application.id).update(
                status=Application.Status.REJECTED
            )

            # Assigne le prestataire et change le statut de la mission
            job.assigned_to = application.applicant
            job.status      = Job.Status.IN_PROGRESS
            if application.proposed_price:
                job.agreed_price = application.proposed_price
            job.save(update_fields=['assigned_to', 'status', 'agreed_price', 'updated_at'])

        # Notifie le prestataire
        send_notification_task.delay(
            recipient_id=str(application.applicant.id),
            notif_type='application_accepted',
            title='Candidature acceptée ! 🎉',
            body=f"Votre candidature pour « {job.title} » a été acceptée.",
            data={'job_id': str(job.id)}
        )

        return Response({'message': 'Candidature acceptée.', 'job_status': job.status})

    @action(
        detail=True, methods=['patch'],
        url_path=r'applications/(?P<app_id>[^/.]+)/reject'
    )
    def reject_application(self, request, pk=None, app_id=None):
        """Refuser une candidature spécifique."""
        job = self.get_object()
        try:
            application = job.applications.get(id=app_id, status=Application.Status.PENDING)
        except Application.DoesNotExist:
            return Response({'error': 'Candidature introuvable.'}, status=status.HTTP_404_NOT_FOUND)

        application.status = Application.Status.REJECTED
        application.save(update_fields=['status', 'updated_at'])

        send_notification_task.delay(
            recipient_id=str(application.applicant.id),
            notif_type='application_rejected',
            title='Candidature non retenue',
            body=f"Votre candidature pour « {job.title} » n'a pas été retenue.",
            data={'job_id': str(job.id)}
        )
        return Response({'message': 'Candidature refusée.'})

    @action(detail=True, methods=['patch'])
    def complete(self, request, pk=None):
        """Marquer une mission comme terminée → invite à laisser un avis."""
        job = self.get_object()
        if job.status != Job.Status.IN_PROGRESS:
            return Response(
                {'error': 'Seules les missions en cours peuvent être terminées.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        job.status       = Job.Status.COMPLETED
        job.completed_at = timezone.now()
        job.save(update_fields=['status', 'completed_at', 'updated_at'])

        # Notifie le prestataire
        if job.assigned_to:
            send_notification_task.delay(
                recipient_id=str(job.assigned_to.id),
                notif_type='job_completed',
                title='Mission terminée',
                body=f"La mission « {job.title} » est marquée terminée. Laissez un avis !",
                data={'job_id': str(job.id)}
            )
        return Response({'message': 'Mission terminée.', 'job_status': job.status})

    @action(detail=True, methods=['patch'])
    def cancel(self, request, pk=None):
        """Annuler une mission (client seulement, si pas encore in_progress)."""
        job = self.get_object()
        if job.status in (Job.Status.COMPLETED, Job.Status.IN_PROGRESS):
            return Response(
                {'error': 'Impossible d\'annuler une mission en cours ou terminée.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        job.status = Job.Status.CANCELLED
        job.save(update_fields=['status', 'updated_at'])
        return Response({'message': 'Mission annulée.'})
