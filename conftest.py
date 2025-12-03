"""
pytest configuration file for the project.
"""

import os
import django
from django.conf import settings

# Ensure Django settings are configured for tests
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")


def pytest_configure(config):
    """Configure pytest for Django."""
    django.setup()
