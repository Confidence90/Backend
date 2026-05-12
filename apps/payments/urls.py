from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register(r'', views.TransactionViewSet, basename='transaction')

urlpatterns = [
    path('webhook/orange/', views.OrangeMoneyWebhookView.as_view(), name='orange-webhook'),
    path('', include(router.urls)),
]
