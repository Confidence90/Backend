"""
BaaraLink – User Model
Custom User avec rôles prestataire / client / admin.
Authentification par téléphone + OTP (pas email obligatoire).
"""
import uuid
import random
import string
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.db import models
from django.utils import timezone
from django.utils.translation import gettext_lazy as _
from django.core.validators import RegexValidator


# ─── Validators ──────────────────────────────────────────────────────────────
phone_validator = RegexValidator(
    regex=r'^\+?[1-9]\d{7,14}$',
    message="Numéro de téléphone invalide. Format : +22370000000"
)


# ─── Manager ─────────────────────────────────────────────────────────────────
class UserManager(BaseUserManager):

    def create_user(self, phone_number, password=None, **extra_fields):
        if not phone_number:
            raise ValueError("Le numéro de téléphone est obligatoire.")
        extra_fields.setdefault('is_active', True)
        user = self.model(phone_number=phone_number, **extra_fields)
        if password:
            user.set_password(password)
        else:
            user.set_unusable_password()
        user.save(using=self._db)
        return user

    def create_superuser(self, phone_number, password, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('role', User.Role.ADMIN)
        extra_fields.setdefault('phone_verified', True)
        if extra_fields.get('is_staff') is not True:
            raise ValueError("Superuser must have is_staff=True.")
        if extra_fields.get('is_superuser') is not True:
            raise ValueError("Superuser must have is_superuser=True.")
        return self.create_user(phone_number, password, **extra_fields)


# ─── User ─────────────────────────────────────────────────────────────────────
class User(AbstractBaseUser, PermissionsMixin):

    class Role(models.TextChoices):
        CLIENT      = 'client',      _('Client')
        PROVIDER    = 'provider',    _('Prestataire')
        ADMIN       = 'admin',       _('Administrateur')

    # Identification
    id             = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    phone_number   = models.CharField(
        max_length=20, unique=True, validators=[phone_validator],
        verbose_name=_("Numéro de téléphone")
    )
    email          = models.EmailField(blank=True, null=True, unique=True)

    # Identity
    first_name     = models.CharField(max_length=80, verbose_name=_("Prénom"))
    last_name      = models.CharField(max_length=80, verbose_name=_("Nom"))

    # Role & Status
    role           = models.CharField(max_length=20, choices=Role.choices, default=Role.CLIENT)
    is_active      = models.BooleanField(default=True)
    is_staff       = models.BooleanField(default=False)
    phone_verified = models.BooleanField(default=False)
    is_banned      = models.BooleanField(default=False)

    # Timestamps
    date_joined    = models.DateTimeField(default=timezone.now)
    last_seen      = models.DateTimeField(null=True, blank=True)

    # Firebase token (push notifications)
    fcm_token      = models.TextField(blank=True, null=True)

    # Language preference (fr / bm = bambara)
    language       = models.CharField(max_length=5, default='fr')

    USERNAME_FIELD  = 'phone_number'
    REQUIRED_FIELDS = ['first_name', 'last_name']

    objects = UserManager()

    class Meta:
        verbose_name = _("Utilisateur")
        verbose_name_plural = _("Utilisateurs")
        indexes = [
            models.Index(fields=['phone_number']),
            models.Index(fields=['role']),
            models.Index(fields=['is_active', 'phone_verified']),
        ]

    def __str__(self):
        return f"{self.get_full_name()} ({self.phone_number})"

    def get_full_name(self):
        return f"{self.first_name} {self.last_name}".strip()

    @property
    def is_provider(self):
        return self.role == self.Role.PROVIDER

    @property
    def is_client(self):
        return self.role == self.Role.CLIENT

    @property
    def is_admin_user(self):
        return self.role == self.Role.ADMIN


# ─── OTP ──────────────────────────────────────────────────────────────────────
class OTPVerification(models.Model):
    """
    OTP (One-Time Password) pour vérification du numéro de téléphone.
    Utilisé aussi bien à l'inscription qu'à la connexion.
    """
    class Purpose(models.TextChoices):
        REGISTER      = 'register',       _('Inscription')
        LOGIN         = 'login',          _('Connexion')
        RESET_PIN     = 'reset_pin',      _('Réinitialisation PIN')
        VERIFY_CHANGE = 'verify_change',  _('Vérification changement')

    id           = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    phone_number = models.CharField(max_length=20, validators=[phone_validator])
    code         = models.CharField(max_length=6)
    purpose      = models.CharField(max_length=20, choices=Purpose.choices, default=Purpose.LOGIN)
    is_used      = models.BooleanField(default=False)
    attempts     = models.PositiveSmallIntegerField(default=0)
    created_at   = models.DateTimeField(auto_now_add=True)
    expires_at   = models.DateTimeField()

    class Meta:
        verbose_name = _("Vérification OTP")
        indexes = [
            models.Index(fields=['phone_number', 'is_used']),
            models.Index(fields=['expires_at']),
        ]

    def __str__(self):
        return f"OTP {self.phone_number} [{self.purpose}]"

    @classmethod
    def generate_code(cls):
        """Génère un code OTP à 6 chiffres."""
        return ''.join(random.choices(string.digits, k=6))

    @classmethod
    def create_for_phone(cls, phone_number, purpose=Purpose.LOGIN):
        from django.conf import settings
        from datetime import timedelta
        # Invalide les anciens OTPs non utilisés
        cls.objects.filter(
            phone_number=phone_number,
            purpose=purpose,
            is_used=False
        ).update(is_used=True)
        expiry = timezone.now() + timedelta(minutes=settings.OTP_EXPIRY_MINUTES)
        return cls.objects.create(
            phone_number=phone_number,
            code=cls.generate_code(),
            purpose=purpose,
            expires_at=expiry
        )

    def is_valid(self):
        return (
            not self.is_used
            and self.expires_at > timezone.now()
            and self.attempts < 5
        )

    def mark_used(self):
        self.is_used = True
        self.save(update_fields=['is_used'])

    def increment_attempts(self):
        self.attempts += 1
        self.save(update_fields=['attempts'])
