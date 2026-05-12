"""BaaraLink – Payments (Mobile Money intégration)"""
import uuid
from django.db import models
from django.conf import settings
from django.core.validators import MinValueValidator
from django.utils.translation import gettext_lazy as _


class Transaction(models.Model):
    class Provider(models.TextChoices):
        ORANGE_MONEY = 'orange_money', _('Orange Money')
        WAVE         = 'wave',         _('Wave')
        MOOV_MONEY   = 'moov_money',   _('Moov Money')
        CASH         = 'cash',         _('Espèces')
        INTERNAL     = 'internal',     _('Portefeuille BaaraLink')

    class Status(models.TextChoices):
        PENDING   = 'pending',   _('En attente')
        SUCCESS   = 'success',   _('Réussi')
        FAILED    = 'failed',    _('Échoué')
        CANCELLED = 'cancelled', _('Annulé')
        REFUNDED  = 'refunded',  _('Remboursé')

    class TransactionType(models.TextChoices):
        PAYMENT    = 'payment',    _('Paiement mission')
        COMMISSION = 'commission', _('Commission plateforme')
        PACK       = 'pack',       _('Achat pack')
        TRAINING   = 'training',   _('Achat formation')
        REFUND     = 'refund',     _('Remboursement')
        WITHDRAWAL = 'withdrawal', _('Retrait')

    id                    = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    job                   = models.ForeignKey(
        'jobs.Job', on_delete=models.SET_NULL, null=True, blank=True,
        related_name='transactions'
    )
    payer                 = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True,
        related_name='paid_transactions'
    )
    payee                 = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True,
        related_name='received_transactions'
    )

    transaction_type      = models.CharField(max_length=20, choices=TransactionType.choices)
    provider              = models.CharField(max_length=20, choices=Provider.choices)
    status                = models.CharField(max_length=20, choices=Status.choices, default=Status.PENDING)

    # Amounts in FCFA
    gross_amount          = models.PositiveIntegerField(validators=[MinValueValidator(1)])
    commission_amount     = models.PositiveIntegerField(default=0)
    net_amount            = models.PositiveIntegerField(default=0)

    # Mobile Money specific
    provider_reference    = models.CharField(max_length=200, blank=True)  # Ref Orange/Wave
    payer_phone           = models.CharField(max_length=20, blank=True)
    payee_phone           = models.CharField(max_length=20, blank=True)

    # Metadata
    description           = models.TextField(blank=True)
    failure_reason        = models.TextField(blank=True)
    raw_response          = models.JSONField(null=True, blank=True)  # Réponse API opérateur

    created_at            = models.DateTimeField(auto_now_add=True)
    updated_at            = models.DateTimeField(auto_now=True)
    completed_at          = models.DateTimeField(null=True, blank=True)

    class Meta:
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['payer', 'status']),
            models.Index(fields=['job', 'status']),
            models.Index(fields=['provider_reference']),
        ]

    def __str__(self):
        return f"TX {self.id} | {self.gross_amount} FCFA [{self.get_status_display()}]"

    @property
    def commission_rate(self):
        if self.gross_amount:
            return self.commission_amount / self.gross_amount
        return 0
