from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User, OTPVerification

@admin.register(User)
class UserAdmin(BaseUserAdmin):
    list_display = ['phone_number', 'first_name', 'last_name', 'role', 'phone_verified', 'is_active', 'date_joined']
    list_filter  = ['role', 'phone_verified', 'is_active', 'is_banned']
    search_fields = ['phone_number', 'first_name', 'last_name', 'email']
    ordering = ['-date_joined']
    fieldsets = (
        (None, {'fields': ('phone_number', 'password')}),
        ('Informations', {'fields': ('first_name', 'last_name', 'email', 'role', 'language')}),
        ('Statut', {'fields': ('is_active', 'is_staff', 'is_superuser', 'phone_verified', 'is_banned')}),
        ('Dates', {'fields': ('date_joined', 'last_seen')}),
        ('Notifications', {'fields': ('fcm_token',)}),
    )
    add_fieldsets = (
        (None, {'classes': ('wide',), 'fields': ('phone_number', 'first_name', 'last_name', 'role', 'password1', 'password2')}),
    )

@admin.register(OTPVerification)
class OTPAdmin(admin.ModelAdmin):
    list_display = ['phone_number', 'purpose', 'is_used', 'attempts', 'created_at', 'expires_at']
    list_filter  = ['purpose', 'is_used']
    search_fields = ['phone_number']
    ordering = ['-created_at']
