from django.http import JsonResponse
from django.db import connection


def health_check(request):
    """
    Health check endpoint for container monitoring.
    Returns 200 OK if the application is healthy.
    """
    try:
        # Check database connectivity
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")

        return JsonResponse({"status": "healthy", "database": "connected"})
    except Exception as e:
        return JsonResponse({"status": "unhealthy", "error": str(e)}, status=503)
