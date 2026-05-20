"""BaaraLink – Jobs & Applications Serializers"""
from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import Job, Application
from apps.profiles.models import Category

User = get_user_model()


class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name', 'slug', 'icon']


class ApplicationLiteSerializer(serializers.ModelSerializer):
    applicant_name = serializers.CharField(source='applicant.get_full_name', read_only=True)
    applicant_phone = serializers.CharField(source='applicant.phone_number', read_only=True)

    class Meta:
        model = Application
        fields = [
            'id', 'applicant', 'applicant_name', 'applicant_phone',
            'status', 'proposed_price', 'available_date', 'cover_letter',
            'created_at',
        ]
        read_only_fields = ['id', 'status', 'created_at']


class JobListSerializer(serializers.ModelSerializer):
    """Sérialiseur léger pour les listes (performance max)."""
    category_name  = serializers.CharField(source='category.name', read_only=True)
    category_icon  = serializers.CharField(source='category.icon', read_only=True)
    client_name    = serializers.CharField(source='client.get_full_name', read_only=True)
    applications_count = serializers.SerializerMethodField()

    class Meta:
        model = Job
        fields = [
            'id', 'title', 'job_type', 'status', 'urgency',
            'city', 'district', 'budget_min', 'budget_max',
            'category_name', 'category_icon',
            'client_name', 'applications_count',
            'start_date', 'created_at',
        ]

    def get_applications_count(self, obj):
        return obj.applications.filter(status=Application.Status.PENDING).count()


class JobDetailSerializer(serializers.ModelSerializer):
    """Sérialiseur complet pour le détail d'une mission."""
    category       = CategorySerializer(read_only=True)
    category_id    = serializers.PrimaryKeyRelatedField(
        queryset=Category.objects.all(), source='category', write_only=True, required=False
    )
    client_name    = serializers.CharField(source='client.get_full_name', read_only=True)
    client_phone   = serializers.CharField(source='client.phone_number', read_only=True)
    assigned_name  = serializers.CharField(source='assigned_to.get_full_name', read_only=True)
    applications   = ApplicationLiteSerializer(many=True, read_only=True)
    user_application = serializers.SerializerMethodField()

    class Meta:
        model = Job
        fields = [
            'id', 'title', 'description', 'job_type', 'status', 'urgency',
            'city', 'district', 'address', 'latitude', 'longitude',
            'budget_min', 'budget_max', 'agreed_price',
            'category', 'category_id',
            'client', 'client_name', 'client_phone',
            'assigned_to', 'assigned_name',
            'start_date', 'end_date', 'duration_hours',
            'is_premium_pack', 'pack_type',
            'is_verified', 'applications', 'user_application',
            'created_at', 'updated_at', 'completed_at',
        ]
        read_only_fields = [
            'id', 'client', 'status', 'assigned_to',
            'is_verified', 'created_at', 'updated_at', 'completed_at',
        ]

    def get_user_application(self, obj):
        request = self.context.get('request')
        if not request or not request.user.is_authenticated:
            return None
        app = obj.applications.filter(applicant=request.user).first()
        return ApplicationLiteSerializer(app).data if app else None


class JobCreateSerializer(serializers.ModelSerializer):
    category_id = serializers.PrimaryKeyRelatedField(
        queryset=Category.objects.filter(is_active=True),
        source='category', required=False, allow_null=True
    )

    class Meta:
        model = Job
        fields = [
            'title', 'description', 'job_type', 'urgency',
            'city', 'district', 'address', 'latitude', 'longitude',
            'budget_min', 'budget_max',
            'category_id', 'start_date', 'end_date', 'duration_hours',
        ]

    def validate(self, data):
        budget_min = data.get('budget_min')
        budget_max = data.get('budget_max')
        if budget_min and budget_max and budget_min > budget_max:
            raise serializers.ValidationError("budget_min doit être ≤ budget_max.")
        return data

    def create(self, validated_data):
        validated_data['client'] = self.context['request'].user
        return super().create(validated_data)


class ApplicationCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Application
        fields = ['cover_letter', 'proposed_price', 'available_date']

    def validate(self, data):
        request = self.context['request']
        job     = self.context['job']

        if job.client == request.user:
            raise serializers.ValidationError("Vous ne pouvez pas postuler à votre propre mission.")
        if job.status != Job.Status.OPEN:
            raise serializers.ValidationError("Cette mission n'accepte plus de candidatures.")
        if Application.objects.filter(job=job, applicant=request.user).exists():
            raise serializers.ValidationError("Vous avez déjà postulé à cette mission.")
        if not request.user.is_provider:
            raise serializers.ValidationError("Seuls les prestataires peuvent postuler.")
        return data

    def create(self, validated_data):
        return Application.objects.create(
            job=self.context['job'],
            applicant=self.context['request'].user,
            **validated_data
        )
