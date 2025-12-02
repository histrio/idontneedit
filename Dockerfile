ARG PYTHON_VERSION=3.13
FROM python:${PYTHON_VERSION}-slim AS base

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

RUN useradd --uid 10001 --create-home --shell /usr/sbin/nologin app \
    && mkdir -p /app /app/static \
    && chown -R app:app /app

WORKDIR /app

FROM base AS runtime

COPY requirements.txt ./
RUN pip install --upgrade pip wheel \
    && pip install -r requirements.txt --no-cache-dir

ENV DJANGO_SETTINGS_MODULE=config.settings \
    DJANGO_STATIC_ROOT=/app/static/ \
    GUNICORN_WORKERS=3 \
    GUNICORN_BIND=0.0.0.0:8000 \
    GUNICORN_MAX_REQUESTS=1000 \
    GUNICORN_MAX_REQUESTS_JITTER=100 \
    PORT=8000


COPY . /app

RUN chown -R app:app /app

USER app

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD curl -fsS "http://127.0.0.1:${PORT}/" || exit 1

CMD ["/bin/sh", "-c", "exec gunicorn config.wsgi:application --bind 0.0.0.0:${PORT:-8000} --workers ${GUNICORN_WORKERS:-3} --access-logfile - --error-logfile -"]
