"""
BaaraLink – Profile & Skills Models
Profil enrichi des utilisateurs (prestataires surtout).
"""
import uuid
from django.db import models
from django.utils.translation import gettext_lazy as _
from django.conf import settings
from django.core.validators import MinValueValidator, MaxValueValidator


class Category(models.Model):
    """Catégories de services (Plomberie, Électricité, Ménage, etc.)"""
    id           = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name         = models.CharField(max_length=100, unique=True)
    name_bambara = models.CharField(max_length=100, blank=True)  # Traduction bambara
    slug         = models.SlugField(unique=True)
    icon         = models.CharField(max_length=50, blank=True)   # Nom icône (ex: "wrench")
    description  = models.TextField(blank=True)
    is_active    = models.BooleanField(default=True)
    order        = models.PositiveSmallIntegerField(default=0)

    class Meta:
        verbose_name = _("Catégorie")
        verbose_name_plural = _("Catégories")
        ordering = ['order', 'name']

    def __str__(self):
        return self.name


class Skill(models.Model):
    """Compétences rattachées à une catégorie."""
    id       = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    category = models.ForeignKey(Category, on_delete=models.CASCADE, related_name='skills')
    name     = models.CharField(max_length=100)
    slug     = models.SlugField()

    class Meta:
        unique_together = ('category', 'slug')

    def __str__(self):
        return f"{self.category.name} > {self.name}"


class Profile(models.Model):
    """
    Profil étendu pour chaque utilisateur.
    Pour les prestataires : compétences, tarifs, localisation, certification.
    """
    class ExperienceLevel(models.TextChoices):
        BEGINNER     = 'beginner',     _('Débutant (< 1 an)')
        INTERMEDIATE = 'intermediate', _('Intermédiaire (1–3 ans)')
        EXPERIENCED  = 'experienced',  _('Expérimenté (3–5 ans)')
        EXPERT       = 'expert',       _('Expert (5+ ans)')

    class AvailabilityStatus(models.TextChoices):
        AVAILABLE    = 'available',    _('Disponible')
        BUSY         = 'busy',         _('Occupé')
        UNAVAILABLE  = 'unavailable',  _('Indisponible')

    id                 = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user               = models.OneToOneField(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='profile'
    )

    # Bio
    bio                = models.TextField(max_length=500, blank=True)
    avatar             = models.ImageField(upload_to='avatars/', blank=True, null=True)
    id_document        = models.ImageField(upload_to='id_docs/', blank=True, null=True)

    # Localisation (Bamako + villes secondaires)
    city               = models.CharField(max_length=100, default='Bamako')
    district           = models.CharField(max_length=100, blank=True)  # Quartier/commune
    latitude           = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    longitude          = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)

    # Provider-specific
    categories         = models.ManyToManyField(Category, blank=True, related_name='providers')
    skills             = models.ManyToManyField(Skill, blank=True, related_name='providers')
    experience_level   = models.CharField(
        max_length=20, choices=ExperienceLevel.choices,
        default=ExperienceLevel.BEGINNER, blank=True
    )
    hourly_rate        = models.PositiveIntegerField(
        null=True, blank=True,
        help_text="Tarif horaire en FCFA"
    )
    min_rate           = models.PositiveIntegerField(
        null=True, blank=True,
        help_text="Tarif minimum par mission en FCFA"
    )

    # Certification & Trust
    is_verified        = models.BooleanField(default=False)       # ID vérifié manuellement
    is_certified       = models.BooleanField(default=False)       # A suivi une formation BaaraLink
    certification_date = models.DateField(null=True, blank=True)
    badge              = models.CharField(max_length=50, blank=True)  # "top_provider", "certified", etc.

    # Availability
    availability       = models.CharField(
        max_length=20, choices=AvailabilityStatus.choices,
        default=AvailabilityStatus.AVAILABLE
    )

    # Stats (dénormalisées pour perf)
    total_missions     = models.PositiveIntegerField(default=0)
    completed_missions = models.PositiveIntegerField(default=0)
    avg_rating         = models.DecimalField(
        max_digits=3, decimal_places=2, default=0.00,
        validators=[MinValueValidator(0), MaxValueValidator(5)]
    )
    total_reviews      = models.PositiveIntegerField(default=0)
    response_rate      = models.PositiveSmallIntegerField(
        default=0,
        validators=[MinValueValidator(0), MaxValueValidator(100)],
        help_text="Taux de réponse en %"
    )

    # Profile completion score (0-100)
    completion_score   = models.PositiveSmallIntegerField(default=0)

    created_at         = models.DateTimeField(auto_now_add=True)
    updated_at         = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = _("Profil")
        indexes = [
            models.Index(fields=['city', 'availability']),
            models.Index(fields=['avg_rating']),
            models.Index(fields=['is_verified', 'is_certified']),
        ]

    def __str__(self):
        return f"Profil de {self.user.get_full_name()}"

    def compute_completion_score(self):
        """Calcule le score de complétion du profil (0-100)."""
        score = 0
        if self.bio: score += 20
        if self.avatar: score += 20
        if self.city: score += 10
        if self.district: score += 5
        if self.categories.exists(): score += 20
        if self.skills.exists(): score += 15
        if self.hourly_rate: score += 10
        self.completion_score = score
        self.save(update_fields=['completion_score'])
        return score

    def update_stats(self):
        """Recalcule les stats après une mission ou un avis."""
        from apps.reviews.models import Review
        reviews = Review.objects.filter(reviewee=self.user, is_active=True)
        self.total_reviews = reviews.count()
        if self.total_reviews > 0:
            total = sum(r.rating for r in reviews)
            self.avg_rating = round(total / self.total_reviews, 2)
        self.save(update_fields=['total_reviews', 'avg_rating'])


class PortfolioItem(models.Model):
    """Photos de réalisations pour les artisans."""
    id          = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    profile     = models.ForeignKey(Profile, on_delete=models.CASCADE, related_name='portfolio')
    image       = models.ImageField(upload_to='portfolio/')
    title       = models.CharField(max_length=150)
    description = models.TextField(blank=True)
    created_at  = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"Portfolio: {self.title} ({self.profile.user.get_full_name()})"
