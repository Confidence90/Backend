from django.contrib import admin
from .models import Job, Application

@admin.register(Job)
class JobAdmin(admin.ModelAdmin):
    list_display  = ['title', 'client', 'category', 'status', 'urgency', 'city', 'budget_min', 'budget_max', 'created_at']
    list_filter   = ['status', 'urgency', 'job_type', 'is_verified', 'city']
    search_fields = ['title', 'description', 'client__phone_number']
    readonly_fields = ['created_at', 'updated_at', 'completed_at']
    actions = ['verify_jobs', 'flag_jobs']

    def verify_jobs(self, request, queryset):
        queryset.update(is_verified=True)
        self.message_user(request, f"{queryset.count()} mission(s) vérifiée(s).")
    verify_jobs.short_description = "Marquer comme vérifiées"

    def flag_jobs(self, request, queryset):
        queryset.update(is_flagged=True)
        self.message_user(request, f"{queryset.count()} mission(s) signalée(s).")
    flag_jobs.short_description = "Signaler"

@admin.register(Application)
class ApplicationAdmin(admin.ModelAdmin):
    list_display = ['applicant', 'job', 'status', 'proposed_price', 'created_at']
    list_filter  = ['status']
    search_fields = ['applicant__phone_number', 'job__title']
