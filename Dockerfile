# Multi-stage build for smaller image
FROM python:3.11-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    POETRY_VIRTUALENVS_CREATE=false

WORKDIR /app

# System deps (build-essential for some libs, psycopg dependencies)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc libpq-dev curl && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt /app/requirements.txt
RUN pip install --upgrade pip && pip install -r requirements.txt gunicorn

# Copy the Django project
COPY . /app

# Create a non-root user
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

# Default environment variables (override in K8s)
ENV DJANGO_SETTINGS_MODULE=CollegeERP.settings \
    DJANGO_SECRET_KEY=change-me \
    DJANGO_DEBUG=False \
    DJANGO_ALLOWED_HOSTS="*" \
    DB_ENGINE=django.db.backends.postgresql \
    DB_NAME=erp \
    DB_USER=erpuser \
    DB_PASSWORD=changeme \
    DB_HOST=postgres \
    DB_PORT=5432

# Healthcheck (optional: simple TCP)
EXPOSE 8000

# Entrypoint runs migrations and static collection before starting gunicorn
COPY docker/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["gunicorn", "CollegeERP.wsgi:application", "--bind", "0.0.0.0:8000", "--workers", "3"]
