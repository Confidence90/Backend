"""BaaraLink – Reviews (Notation bidirectionnelle)"""
import uuid
from django.db import models
from django.conf import settings
from django.core.validators import MinValueValidator, MaxValueValidator
from django.utils.translation import gettext_lazy as _
from django.core.validators import MinLengthValidator

class Review(models.Model):
    """
    Système de notation bidirectionnel.
    - Client → Prestataire (après mission)
    - Prestataire → Client (comportement, paiement)
    """
    id         = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    job        = models.ForeignKey(
        'jobs.Job', on_delete=models.CASCADE, related_name='reviews'
    )
    reviewer   = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE,
        related_name='given_reviews'
    )
    reviewee   = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE,
        related_name='received_reviews'
    )
    rating     = models.PositiveSmallIntegerField(
        validators=[MinValueValidator(1), MaxValueValidator(5)]
    )
    comment    = models.TextField( max_length=1000, blank=True,validators=[MinLengthValidator(20)])

    # Critères détaillés (optionnels)
    quality_rating       = models.PositiveSmallIntegerField(null=True, blank=True,
                           validators=[MinValueValidator(1), MaxValueValidator(5)])
    punctuality_rating   = models.PositiveSmallIntegerField(null=True, blank=True,
                           validators=[MinValueValidator(1), MaxValueValidator(5)])
    communication_rating = models.PositiveSmallIntegerField(null=True, blank=True,
                           validators=[MinValueValidator(1), MaxValueValidator(5)])

    is_active  = models.BooleanField(default=True)   # False si modéré
    response   = models.TextField(blank=True)         # Réponse du reviewee
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('job', 'reviewer', 'reviewee')
        indexes = [
            models.Index(fields=['reviewee', 'is_active']),
            models.Index(fields=['reviewer']),
        ]

    def __str__(self):
        return f"{self.reviewer} → {self.reviewee} : {self.rating}★"

    def save(self, *args, **kwargs):
        super().save(*args, **kwargs)
        # Mettre à jour les stats du profil après chaque avis
        try:
            self.reviewee.profile.update_stats()
        except Exception:
            pass
