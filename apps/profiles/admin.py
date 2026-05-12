from django.contrib import admin
from .models import Profile, Category, Skill, PortfolioItem

@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display  = ['name', 'slug', 'is_active', 'order']
    prepopulated_fields = {'slug': ('name',)}
    list_editable = ['is_active', 'order']

@admin.register(Skill)
class SkillAdmin(admin.ModelAdmin):
    list_display = ['name', 'category']
    list_filter  = ['category']

@admin.register(Profile)
class ProfileAdmin(admin.ModelAdmin):
    list_display  = ['user', 'city', 'avg_rating', 'is_verified', 'is_certified', 'availability']
    list_filter   = ['is_verified', 'is_certified', 'availability', 'city']
    search_fields = ['user__phone_number', 'user__first_name', 'user__last_name']
    filter_horizontal = ['categories', 'skills']

@admin.register(PortfolioItem)
class PortfolioItemAdmin(admin.ModelAdmin):
    list_display = ['profile', 'title', 'created_at']
