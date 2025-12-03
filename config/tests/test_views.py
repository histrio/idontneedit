import pytest
from django.test import Client
from django.urls import reverse
from unittest.mock import patch


@pytest.fixture
def client():
    """Provide a Django test client."""
    return Client()


@pytest.mark.django_db
class TestHealthCheck:
    """Test suite for health check endpoint."""

    def test_health_check_success(self, client):
        """Test that health check returns 200 when database is connected."""
        response = client.get(reverse("health_check"))

        assert response.status_code == 200
        assert response["Content-Type"] == "application/json"

        data = response.json()
        assert data["status"] == "healthy"
        assert data["database"] == "connected"

    def test_health_check_database_failure(self, client):
        """Test that health check returns 503 when database connection fails."""
        with patch("config.views.connection") as mock_connection:
            mock_connection.cursor.return_value.__enter__.return_value.execute.side_effect = Exception(
                "Database connection failed"
            )

            response = client.get(reverse("health_check"))

            assert response.status_code == 503

            data = response.json()
            assert data["status"] == "unhealthy"
            assert data["database"] == "disconnected"

    def test_health_check_only_allows_get(self, client):
        """Test that health check endpoint only accepts GET requests."""
        response = client.post(reverse("health_check"))
        assert response.status_code == 405

        response = client.put(reverse("health_check"))
        assert response.status_code == 405

        response = client.delete(reverse("health_check"))
        assert response.status_code == 405
