# profiles/urls.py
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register(r'', views.ProfileViewSet, basename='profile')

urlpatterns = [
    path('categories/', views.CategoryListView.as_view(), name='category-list'),
    path('', include(router.urls)),
]
