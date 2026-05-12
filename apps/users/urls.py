"""BaaraLink – Users URL Routes"""
from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from . import views

urlpatterns = [
    # Registration (phone + OTP)
    path('register/',              views.RegisterRequestView.as_view(),  name='register-request'),
    path('register/verify/',       views.RegisterVerifyView.as_view(),   name='register-verify'),

    # Login (phone + OTP)
    path('login/',                 views.LoginRequestView.as_view(),     name='login-request'),
    path('login/verify/',          views.LoginVerifyView.as_view(),      name='login-verify'),

    # Token management
    path('token/refresh/',         TokenRefreshView.as_view(),           name='token-refresh'),
    path('logout/',                views.LogoutView.as_view(),            name='logout'),

    # Current user
    path('me/',                    views.MeView.as_view(),               name='me'),
    path('fcm-token/',             views.UpdateFCMTokenView.as_view(),   name='fcm-token'),
]
