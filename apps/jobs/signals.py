from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import Job, Application

@receiver(post_save, sender=Application)
def update_job_application_count(sender, instance, created, **kwargs):
    """Log or react to new applications."""
    pass
