from rest_framework import viewsets, status, mixins
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.views import APIView
from .models import Transaction
from .serializers import TransactionSerializer, InitiatePaymentSerializer
from .services import PaymentService
from apps.jobs.models import Job
import logging

logger = logging.getLogger('apps.payments')


class TransactionViewSet(mixins.ListModelMixin, mixins.RetrieveModelMixin,
                          viewsets.GenericViewSet):
    serializer_class   = TransactionSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Transaction.objects.filter(payer=self.request.user).order_by('-created_at')

    @action(detail=False, methods=['post'], url_path='initiate')
    def initiate(self, request):
        serializer = InitiatePaymentSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        try:
            job = Job.objects.get(id=data['job_id'], client=request.user)
        except Job.DoesNotExist:
            return Response({'error': 'Mission introuvable.'}, status=status.HTTP_404_NOT_FOUND)

        if job.status != Job.Status.COMPLETED:
            return Response({'error': 'Payez uniquement les missions terminées.'}, status=400)

        tx = PaymentService.initiate_payment(
            job=job,
            payer=request.user,
            provider=data['provider'],
            payer_phone=data['payer_phone'],
            amount=data['amount'],
        )
        return Response(TransactionSerializer(tx).data,
                        status=status.HTTP_201_CREATED if tx.status == Transaction.Status.SUCCESS
                        else status.HTTP_402_PAYMENT_REQUIRED)


class OrangeMoneyWebhookView(APIView):
    """POST /payments/webhook/orange/ — Webhook Orange Money."""
    permission_classes = [AllowAny]

    def post(self, request):
        data = request.data
        logger.info(f"Orange Money webhook: {data}")
        ref = data.get('txnid') or data.get('order_id')
        if ref:
            try:
                tx = Transaction.objects.get(id=ref)
                if data.get('status') in ('SUCCESSFULL', 'SUCCESS'):
                    from django.utils import timezone
                    tx.status = Transaction.Status.SUCCESS
                    tx.completed_at = timezone.now()
                    tx.provider_reference = data.get('pay_token', '')
                else:
                    tx.status = Transaction.Status.FAILED
                tx.raw_response = data
                tx.save(update_fields=['status', 'completed_at', 'provider_reference', 'raw_response'])
            except Transaction.DoesNotExist:
                pass
        return Response({'status': 'ok'})
