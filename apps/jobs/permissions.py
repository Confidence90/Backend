"""BaaraLink – Custom Permissions"""
from rest_framework.permissions import BasePermission, SAFE_METHODS


class IsClient(BasePermission):
    """Seuls les clients peuvent créer des missions."""
    message = "Seuls les clients peuvent effectuer cette action."

    def has_permission(self, request, view):
        return bool(request.user and request.user.is_authenticated and request.user.is_client)


class IsProvider(BasePermission):
    """Seuls les prestataires peuvent postuler."""
    message = "Seuls les prestataires peuvent effectuer cette action."

    def has_permission(self, request, view):
        return bool(request.user and request.user.is_authenticated and request.user.is_provider)


class IsOwnerOrReadOnly(BasePermission):
    """L'auteur peut modifier, les autres lisent seulement."""
    def has_object_permission(self, request, view, obj):
        if request.method in SAFE_METHODS:
            return True
        owner_field = getattr(obj, 'client', None) or getattr(obj, 'user', None)
        return owner_field == request.user


class IsJobClient(BasePermission):
    """Seul le client propriétaire d'une mission peut la modifier."""
    def has_object_permission(self, request, view, obj):
        return obj.client == request.user


class IsApplicationApplicant(BasePermission):
    def has_object_permission(self, request, view, obj):
        return obj.applicant == request.user
