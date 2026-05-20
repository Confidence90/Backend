"""BaaraLink – Notifications (Push + In-App)"""
import uuid
from django.db import models
from django.conf import settings
from django.utils.translation import gettext_lazy as _


class Notification(models.Model):
    class NotificationType(models.TextChoices):
        NEW_APPLICATION  = 'new_application',  _('Nouvelle candidature')
        APPLICATION_ACCEPTED = 'app_accepted', _('Candidature acceptée')
        APPLICATION_REJECTED = 'app_rejected', _('Candidature refusée')
        JOB_COMPLETED    = 'job_completed',    _('Mission terminée')
        NEW_REVIEW       = 'new_review',       _('Nouvel avis')
        PAYMENT_RECEIVED = 'payment_received', _('Paiement reçu')
        NEW_MESSAGE      = 'new_message',      _('Nouveau message')
        MATCH_FOUND      = 'match_found',      _('Profil correspondant trouvé')
        SYSTEM           = 'system',           _('Système')

    id           = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    recipient    = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE,
        related_name='notifications'
    )
    notif_type   = models.CharField(max_length=30, choices=NotificationType.choices)
    title        = models.CharField(max_length=200)
    body         = models.TextField()
    data         = models.JSONField(null=True, blank=True)  # Payload extra (job_id, etc.)
    is_read      = models.BooleanField(default=False)
    is_sent      = models.BooleanField(default=False)  # Envoyé via FCM ?
    created_at   = models.DateTimeField(auto_now_add=True)
    read_at      = models.DateTimeField(null=True, blank=True)

    class Meta:
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['recipient', 'is_read']),
            models.Index(fields=['-created_at']),
        ]

    def __str__(self):
        return f"[{self.notif_type}] → {self.recipient} | {self.title}"

    def mark_read(self):
        from django.utils import timezone
        self.is_read = True
        self.read_at = timezone.now()
        self.save(update_fields=['is_read', 'read_at'])
