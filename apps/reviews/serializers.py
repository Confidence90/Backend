from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import Review
from apps.jobs.models import Job

User = get_user_model()

class ReviewSerializer(serializers.ModelSerializer):
    reviewer_name = serializers.CharField(source='reviewer.get_full_name', read_only=True)
    reviewer_avatar = serializers.SerializerMethodField()

    class Meta:
        model  = Review
        fields = [
            'id', 'job', 'reviewer', 'reviewer_name', 'reviewer_avatar',
            'reviewee', 'rating', 'comment',
            'quality_rating', 'punctuality_rating', 'communication_rating',
            'response', 'created_at',
        ]
        read_only_fields = ['id', 'reviewer', 'created_at']

    def get_reviewer_avatar(self, obj):
        try:
            avatar = obj.reviewer.profile.avatar
            return avatar.url if avatar else None
        except Exception:
            return None

    def validate(self, data):
        request = self.context['request']
        job     = data.get('job')
        reviewee = data.get('reviewee')

        if job.status != Job.Status.COMPLETED:
            raise serializers.ValidationError("Vous ne pouvez noter qu'après la fin de la mission.")
        if job.client != request.user and job.assigned_to != request.user:
            raise serializers.ValidationError("Vous ne participez pas à cette mission.")
        if reviewee not in (job.client, job.assigned_to):
            raise serializers.ValidationError("La personne notée ne fait pas partie de cette mission.")
        if reviewee == request.user:
            raise serializers.ValidationError("Vous ne pouvez pas vous noter vous-même.")
        if Review.objects.filter(job=job, reviewer=request.user, reviewee=reviewee).exists():
            raise serializers.ValidationError("Vous avez déjà laissé un avis pour cette mission.")
        return data

    def create(self, validated_data):
        validated_data['reviewer'] = self.context['request'].user
        return super().create(validated_data)
