"""BaaraLink – SMS Service (OTP delivery)"""
import logging
from django.conf import settings

logger = logging.getLogger('apps.users')


class SMSService:
    @staticmethod
    def send_otp(phone_number: str, code: str) -> bool:
        """
        Envoie un OTP par SMS.
        En dev: log seulement. En prod: Twilio ou opérateur local.
        """
        message = f"BaaraLink – Votre code de vérification : {code}\nValable {settings.OTP_EXPIRY_MINUTES} minutes."

        if settings.DEBUG:
            # Dev: affiche le code dans les logs
            logger.info(f"[DEV OTP] {phone_number} → Code: {code}")
            return True

        provider = settings.SMS_PROVIDER
        try:
            if provider == 'twilio':
                return SMSService._send_twilio(phone_number, message)
            elif provider == 'orange_mali':
                return SMSService._send_orange_mali(phone_number, message)
            else:
                logger.warning(f"Unknown SMS provider: {provider}")
                return False
        except Exception as e:
            logger.error(f"SMS send failed for {phone_number}: {e}")
            return False

    @staticmethod
    def _send_twilio(phone: str, message: str) -> bool:
        from twilio.rest import Client
        client = Client(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN)
        client.messages.create(body=message, from_=settings.TWILIO_FROM_NUMBER, to=phone)
        return True

    @staticmethod
    def _send_orange_mali(phone: str, message: str) -> bool:
        # TODO: Intégrer l'API SMS Orange Mali
        import requests
        resp = requests.post(
            "https://api.orange.com/smsmessaging/v1/outbound/tel%3A%2B223XXXXXXXXX/requests",
            json={"outboundSMSMessageRequest": {
                "address": f"tel:{phone}",
                "senderAddress": "tel:+223XXXXXXXXX",
                "outboundSMSTextMessage": {"message": message}
            }},
            headers={"Authorization": f"Bearer {settings.ORANGE_MONEY_API_KEY}"}
        )
        return resp.status_code == 201
