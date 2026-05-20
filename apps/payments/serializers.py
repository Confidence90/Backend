from rest_framework import serializers
from .models import Transaction

class TransactionSerializer(serializers.ModelSerializer):
    class Meta:
        model  = Transaction
        fields = [
            'id', 'job', 'payer', 'payee', 'transaction_type',
            'provider', 'status', 'gross_amount', 'commission_amount',
            'net_amount', 'provider_reference', 'payer_phone',
            'description', 'created_at', 'completed_at',
        ]
        read_only_fields = [
            'id', 'commission_amount', 'net_amount',
            'provider_reference', 'status', 'created_at', 'completed_at',
        ]


class InitiatePaymentSerializer(serializers.Serializer):
    job_id       = serializers.UUIDField()
    provider     = serializers.ChoiceField(choices=Transaction.Provider.choices)
    payer_phone  = serializers.CharField(max_length=20)
    amount       = serializers.IntegerField(min_value=500)

    def validate_provider(self, val):
        if val == Transaction.Provider.INTERNAL:
            raise serializers.ValidationError("Utilisez l'endpoint portefeuille pour les paiements internes.")
        return val
