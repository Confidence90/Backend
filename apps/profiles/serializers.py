"""BaaraLink – Profiles Serializers"""
from rest_framework import serializers
from .models import Profile, Category, Skill, PortfolioItem


class SkillSerializer(serializers.ModelSerializer):
    class Meta:
        model  = Skill
        fields = ['id', 'name', 'slug']


class CategorySerializer(serializers.ModelSerializer):
    skills = SkillSerializer(many=True, read_only=True)

    class Meta:
        model  = Category
        fields = ['id', 'name', 'name_bambara', 'slug', 'icon', 'description', 'skills']


class PortfolioItemSerializer(serializers.ModelSerializer):
    class Meta:
        model  = PortfolioItem
        fields = ['id', 'image', 'title', 'description', 'created_at']
        read_only_fields = ['id', 'created_at']


class ProfileListSerializer(serializers.ModelSerializer):
    """Sérialiseur léger pour la liste des prestataires."""
    user_name       = serializers.CharField(source='user.get_full_name', read_only=True)
    user_phone      = serializers.CharField(source='user.phone_number', read_only=True)
    categories      = serializers.SlugRelatedField(many=True, slug_field='name', read_only=True)
    distance_km     = serializers.SerializerMethodField()

    class Meta:
        model  = Profile
        fields = [
            'id', 'user', 'user_name', 'user_phone', 'avatar',
            'city', 'district', 'categories',
            'avg_rating', 'total_reviews', 'completed_missions',
            'hourly_rate', 'min_rate', 'availability',
            'is_verified', 'is_certified', 'badge',
            'completion_score', 'distance_km',
        ]

    def get_distance_km(self, obj):
        # Injecté par le matching engine si disponible
        return getattr(obj, '_distance_km', None)


class ProfileDetailSerializer(serializers.ModelSerializer):
    user_name  = serializers.CharField(source='user.get_full_name', read_only=True)
    categories = CategorySerializer(many=True, read_only=True)
    skills     = SkillSerializer(many=True, read_only=True)
    portfolio  = PortfolioItemSerializer(many=True, read_only=True)

    class Meta:
        model  = Profile
        fields = [
            'id', 'user', 'user_name', 'avatar', 'bio',
            'city', 'district', 'latitude', 'longitude',
            'categories', 'skills',
            'experience_level', 'hourly_rate', 'min_rate',
            'is_verified', 'is_certified', 'certification_date', 'badge',
            'availability',
            'total_missions', 'completed_missions',
            'avg_rating', 'total_reviews', 'response_rate',
            'completion_score', 'portfolio',
            'created_at', 'updated_at',
        ]
        read_only_fields = [
            'id', 'user', 'is_verified', 'is_certified', 'certification_date',
            'total_missions', 'completed_missions',
            'avg_rating', 'total_reviews', 'response_rate',
            'completion_score', 'created_at', 'updated_at',
        ]


class ProfileUpdateSerializer(serializers.ModelSerializer):
    category_ids = serializers.PrimaryKeyRelatedField(
        queryset=Category.objects.filter(is_active=True),
        many=True, source='categories', required=False
    )
    skill_ids = serializers.PrimaryKeyRelatedField(
        queryset=Skill.objects.all(),
        many=True, source='skills', required=False
    )

    class Meta:
        model  = Profile
        fields = [
            'bio', 'avatar', 'city', 'district',
            'latitude', 'longitude',
            'category_ids', 'skill_ids',
            'experience_level', 'hourly_rate', 'min_rate',
            'availability',
        ]

    def update(self, instance, validated_data):
        categories = validated_data.pop('categories', None)
        skills     = validated_data.pop('skills', None)
        for attr, val in validated_data.items():
            setattr(instance, attr, val)
        if categories is not None:
            instance.categories.set(categories)
        if skills is not None:
            instance.skills.set(skills)
        instance.save()
        instance.compute_completion_score()
        return instance
