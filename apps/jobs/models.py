"""
BaaraLink – Jobs / Missions Models
Gestion complète des missions ponctuelles et offres d'emploi.
"""
import uuid
from django.db import models
from django.utils.translation import gettext_lazy as _
from django.conf import settings
from django.core.validators import MinValueValidator


class Job(models.Model):
    """
    Mission ou offre d'emploi publiée par un client ou une entreprise.
    Couvre aussi bien les missions ponctuelles (plombier 1 jour)
    que les offres d'emploi formelles (CDD, CDI).
    """
    class JobType(models.TextChoices):
        MISSION    = 'mission',    _('Mission ponctuelle')
        FULL_TIME  = 'full_time',  _('Emploi plein temps (CDI)')
        PART_TIME  = 'part_time',  _('Emploi temps partiel')
        CONTRACT   = 'contract',   _('CDD / Contrat')
        FREELANCE  = 'freelance',  _('Freelance')
        INTERNSHIP = 'internship', _('Stage')

    class Status(models.TextChoices):
        DRAFT       = 'draft',       _('Brouillon')
        OPEN        = 'open',        _('Ouvert')
        IN_PROGRESS = 'in_progress', _('En cours')
        COMPLETED   = 'completed',   _('Terminé')
        CANCELLED   = 'cancelled',   _('Annulé')
        DISPUTED    = 'disputed',    _('Litige')

    class UrgencyLevel(models.TextChoices):
        LOW    = 'low',    _('Pas urgent')
        MEDIUM = 'medium', _('Sous 48h')
        HIGH   = 'high',   _('Urgent (aujourd\'hui)')

    id              = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    client          = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE,
        related_name='posted_jobs', verbose_name=_("Client")
    )
    assigned_to     = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.SET_NULL,
        null=True, blank=True, related_name='assigned_jobs',
        verbose_name=_("Prestataire assigné")
    )
    category        = models.ForeignKey(
        'profiles.Category', on_delete=models.SET_NULL,
        null=True, related_name='jobs'
    )

    # Content
    title           = models.CharField(max_length=200)
    description     = models.TextField()
    job_type        = models.CharField(max_length=20, choices=JobType.choices, default=JobType.MISSION)
    status          = models.CharField(max_length=20, choices=Status.choices, default=Status.OPEN)
    urgency         = models.CharField(max_length=10, choices=UrgencyLevel.choices, default=UrgencyLevel.LOW)

    # Location
    city            = models.CharField(max_length=100, default='Bamako')
    district        = models.CharField(max_length=100, blank=True)
    address         = models.TextField(blank=True)
    latitude        = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    longitude       = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)

    # Budget
    budget_min      = models.PositiveIntegerField(
        null=True, blank=True, validators=[MinValueValidator(1000)],
        help_text="Budget minimum en FCFA"
    )
    budget_max      = models.PositiveIntegerField(null=True, blank=True)
    agreed_price    = models.PositiveIntegerField(null=True, blank=True)

    # Schedule
    start_date      = models.DateField(null=True, blank=True)
    end_date        = models.DateField(null=True, blank=True)
    duration_hours  = models.PositiveSmallIntegerField(null=True, blank=True)

    # Pack Premium (délégation sélection)
    is_premium_pack = models.BooleanField(default=False)
    pack_type       = models.CharField(max_length=20, blank=True)  # 'basic' | 'premium'

    # Moderation
    is_verified     = models.BooleanField(default=False)
    is_flagged      = models.BooleanField(default=False)
    flag_reason     = models.TextField(blank=True)

    # Timestamps
    created_at      = models.DateTimeField(auto_now_add=True)
    updated_at      = models.DateTimeField(auto_now=True)
    completed_at    = models.DateTimeField(null=True, blank=True)

    class Meta:
        verbose_name = _("Mission / Offre")
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['status', 'city']),
            models.Index(fields=['client']),
            models.Index(fields=['category', 'status']),
            models.Index(fields=['-created_at']),
        ]

    def __str__(self):
        return f"[{self.get_status_display()}] {self.title}"

    @property
    def is_open(self):
        return self.status == self.Status.OPEN

    def get_applications_count(self):
        return self.applications.filter(status=Application.Status.PENDING).count()


class Application(models.Model):
    """Candidature d'un prestataire à une mission."""
    class Status(models.TextChoices):
        PENDING   = 'pending',   _('En attente')
        ACCEPTED  = 'accepted',  _('Acceptée')
        REJECTED  = 'rejected',  _('Refusée')
        WITHDRAWN = 'withdrawn', _('Retirée')

    id           = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    job          = models.ForeignKey(Job, on_delete=models.CASCADE, related_name='applications')
    applicant    = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE,
        related_name='applications'
    )
    status       = models.CharField(max_length=20, choices=Status.choices, default=Status.PENDING)
    cover_letter = models.TextField(blank=True, max_length=1000)
    proposed_price = models.PositiveIntegerField(null=True, blank=True)
    available_date = models.DateField(null=True, blank=True)
    created_at   = models.DateTimeField(auto_now_add=True)
    updated_at   = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ('job', 'applicant')
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['job', 'status']),
            models.Index(fields=['applicant', 'status']),
        ]

    def __str__(self):
        return f"{self.applicant.get_full_name()} → {self.job.title} [{self.status}]"
