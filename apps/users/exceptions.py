from rest_framework.views import exception_handler
from rest_framework.response import Response
from rest_framework import status

def custom_exception_handler(exc, context):
    response = exception_handler(exc, context)
    if response is not None:
        errors = response.data
        # Normalise les erreurs en format uniforme
        if isinstance(errors, list):
            message = errors[0] if errors else 'Erreur inconnue'
        elif isinstance(errors, dict):
            first_key = next(iter(errors))
            val = errors[first_key]
            message = val[0] if isinstance(val, list) else val
        else:
            message = str(errors)
        response.data = {
            'success': False,
            'message': str(message),
            'errors': errors,
            'status_code': response.status_code,
        }
    return response
