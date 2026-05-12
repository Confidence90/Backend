"""
BaaraLink – Payment Service (Mock + Real stubs)
En production: intégrer Orange Money et Wave APIs.
"""
import logging
import uuid
from django.conf import settings
from django.utils import timezone
from .models import Transaction

logger = logging.getLogger('apps.payments')


class PaymentService:

    @staticmethod
    def compute_amounts(gross_amount: int) -> dict:
        rate = settings.COMMISSION_RATE
        commission = round(gross_amount * rate)
        return {
            'gross_amount':      gross_amount,
            'commission_amount': commission,
            'net_amount':        gross_amount - commission,
        }

    @staticmethod
    def initiate_payment(job, payer, provider: str, payer_phone: str, amount: int) -> Transaction:
        amounts = PaymentService.compute_amounts(amount)
        tx = Transaction.objects.create(
            job=job,
            payer=payer,
            payee=job.assigned_to,
            transaction_type=Transaction.TransactionType.PAYMENT,
            provider=provider,
            status=Transaction.Status.PENDING,
            payer_phone=payer_phone,
            payee_phone=job.assigned_to.phone_number if job.assigned_to else '',
            description=f"Paiement mission: {job.title}",
            **amounts,
        )
        # Appel API opérateur (mock en dev)
        if settings.DEBUG:
            success = PaymentService._mock_payment(tx)
        elif provider == Transaction.Provider.ORANGE_MONEY:
            success = PaymentService._orange_money_request(tx)
        elif provider == Transaction.Provider.WAVE:
            success = PaymentService._wave_request(tx)
        else:
            success = False

        if success:
            tx.status       = Transaction.Status.SUCCESS
            tx.completed_at = timezone.now()
            tx.provider_reference = f"MOCK-{uuid.uuid4().hex[:12].upper()}"
        else:
            tx.status         = Transaction.Status.FAILED
            tx.failure_reason = "Paiement refusé par l'opérateur."
        tx.save(update_fields=['status', 'completed_at', 'provider_reference', 'failure_reason'])
        return tx

    @staticmethod
    def _mock_payment(tx: Transaction) -> bool:
        """Simule un paiement réussi en environnement de développement."""
        logger.info(f"[MOCK PAYMENT] TX {tx.id} | {tx.gross_amount} FCFA via {tx.provider}")
        return True  # 100% succès en dev

    @staticmethod
    def _orange_money_request(tx: Transaction) -> bool:
        import requests
        try:
            resp = requests.post(
                f"{settings.ORANGE_MONEY_API_URL}/webpayment",
                json={
                    "merchant_key": settings.ORANGE_MONEY_API_KEY,
                    "currency": "OUV",
                    "order_id": str(tx.id),
                    "amount": tx.gross_amount,
                    "return_url": "https://baaralink.ml/payment/callback",
                    "cancel_url": "https://baaralink.ml/payment/cancel",
                    "notif_url": "https://baaralink.ml/api/v1/payments/webhook/orange/",
                    "lang": "fr",
                    "reference": str(tx.id),
                },
                timeout=10
            )
            data = resp.json()
            tx.raw_response = data
            return resp.status_code == 200 and data.get('status') == 'SUCCESS'
        except Exception as e:
            logger.error(f"Orange Money error: {e}")
            tx.failure_reason = str(e)
            return False

    @staticmethod
    def _wave_request(tx: Transaction) -> bool:
        import requests
        try:
            resp = requests.post(
                f"{settings.WAVE_API_URL}/checkout/sessions",
                json={
                    "amount": str(tx.gross_amount),
                    "currency": "XOF",
                    "error_url": "https://baaralink.ml/payment/error",
                    "success_url": "https://baaralink.ml/payment/success",
                    "client_reference": str(tx.id),
                },
                headers={"Authorization": f"Bearer {settings.WAVE_API_KEY}"},
                timeout=10
            )
            data = resp.json()
            tx.raw_response = data
            return resp.status_code == 200
        except Exception as e:
            logger.error(f"Wave error: {e}")
            return False
