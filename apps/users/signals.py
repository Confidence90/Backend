"""BaaraLink – Signals utilisateurs"""
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.contrib.auth import get_user_model

User = get_user_model()


@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    """Crée automatiquement un profil vide lors de la création d'un compte."""
    if created:
        from apps.profiles.models import Profile
        Profile.objects.get_or_create(user=instance)
