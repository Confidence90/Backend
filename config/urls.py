"""BaaraLink – Root URL Configuration"""
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView, SpectacularRedocView
from django.http import JsonResponse
API_V1 = 'api/v1/'
def api_root(request):
    return JsonResponse({
        "name": "BaaraLink API",
        "version": "v1",
        "status": "running",
        "docs": "/api/docs/",
        "schema": "/api/schema/",
        "endpoints": {
            "auth": "/api/v1/auth/",
            "profiles": "/api/v1/profiles/",
            "jobs": "/api/v1/jobs/",
            "reviews": "/api/v1/reviews/",
            "payments": "/api/v1/payments/",
            "notifications": "/api/v1/notifications/",
            "matching": "/api/v1/matching/"
        }
    })
def health_check(request):
    return JsonResponse({
        "status": "ok",
        "service": "BaaraLink API"
    })
urlpatterns = [
    path('api/', api_root),
    # Admin
    path('admin/', admin.site.urls),
    path('api/health/', health_check),
    # API Docs (Swagger + Redoc)
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
    path('api/redoc/', SpectacularRedocView.as_view(url_name='schema'), name='redoc'),

    # App routes
    path(API_V1 + 'auth/',          include('apps.users.urls')),
    path(API_V1 + 'profiles/',      include('apps.profiles.urls')),
    # path(API_V1 + 'services/',      include('apps.services.urls')),
    path(API_V1 + 'jobs/',          include('apps.jobs.urls')),
    path(API_V1 + 'reviews/',       include('apps.reviews.urls')),
    path(API_V1 + 'payments/',      include('apps.payments.urls')),
    path(API_V1 + 'notifications/', include('apps.notifications.urls')),
    path(API_V1 + 'matching/',      include('apps.matching.urls')),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
