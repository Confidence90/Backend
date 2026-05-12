"""BaaraLink – Notification Celery Tasks"""
import logging
from celery import shared_task
from django.contrib.auth import get_user_model

logger = logging.getLogger('apps.notifications')
User = get_user_model()


@shared_task(bind=True, max_retries=3)
def send_notification_task(self, recipient_id, notif_type, title, body, data=None):
    """Crée une notification in-app et envoie un push FCM."""
    try:
        from apps.notifications.models import Notification
        user = User.objects.get(id=recipient_id)
        notif = Notification.objects.create(
            recipient=user,
            notif_type=notif_type,
            title=title,
            body=body,
            data=data or {},
        )
        # Envoi FCM si token disponible
        if user.fcm_token:
            _send_fcm(user.fcm_token, title, body, data or {})
            notif.is_sent = True
            notif.save(update_fields=['is_sent'])
        return f"Notif {notif.id} sent to {user.phone_number}"
    except User.DoesNotExist:
        logger.warning(f"User {recipient_id} not found for notification")
    except Exception as exc:
        logger.error(f"Notification task failed: {exc}")
        raise self.retry(exc=exc, countdown=60)


def _send_fcm(token: str, title: str, body: str, data: dict):
    """Envoi push Firebase Cloud Messaging."""
    try:
        import firebase_admin
        from firebase_admin import messaging
        msg = messaging.Message(
            notification=messaging.Notification(title=title, body=body),
            data={k: str(v) for k, v in data.items()},
            token=token,
        )
        messaging.send(msg)
    except Exception as e:
        logger.error(f"FCM send failed: {e}")
