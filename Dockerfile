# define an alias for the specific python version used in this file.
FROM python:3.11.5-slim-bullseye as builder

ARG BUILD_ENVIRONMENT=production

# Install build dependencies and psycopg2 dependencies in one layer to reduce image size
RUN apt-get update && apt-get install --no-install-recommends -y \
    libpq-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and build wheels
COPY ./requirements/${BUILD_ENVIRONMENT}.txt /requirements.txt
RUN pip wheel --no-cache-dir --wheel-dir /wheels -r /requirements.txt

# Final stage
FROM python:3.11.5-slim-bullseye

ARG BUILD_ENVIRONMENT=production
ARG APP_HOME=/app
ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1

WORKDIR ${APP_HOME}

# Install runtime dependencies and cleanup
RUN apt-get update && apt-get install --no-install-recommends -y \
    libpq-dev \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && rm -rf /var/lib/apt/lists/*

# Copy the pre-built wheels and install them
COPY --from=builder /wheels /wheels
RUN pip install --no-cache-dir /wheels/* \
    && rm -rf /wheels

# Copy the entrypoint script and remove windows line endings
COPY ./deployment/scripts/entrypoint /entrypoint
RUN sed -i 's/\r$//g' /entrypoint \
  && chmod +x /entrypoint

# Copy the start-django scripts and remove windows line endings
COPY ./deployment/scripts/start-django /start-django
RUN sed -i 's/\r$//g' /start-django \
  && chmod +x /start-django

# Depending on the BUILD_ENVIRONMENT, we perform different actions:
# For a local environment, we install development tools and set up a user with sudo access.
# For other environments (e.g., production), we create a system user without extra privileges.
RUN if [ "$BUILD_ENVIRONMENT" = "local" ]; then \
    # Update the package list
    apt-get update && \
    # Install development tools and utilities
    apt-get install --no-install-recommends -y sudo git bash-completion nano ssh gettext && \
    # Create a group with a specified GID for the django user
    groupadd --gid 1000 django && \
    # Create a user 'django' with the specified UID/GID, bash shell, and home directory
    useradd --uid 1000 --gid django --shell /bin/bash --create-home django && \
    # Give the django user passwordless sudo access
    echo 'django ALL=(root) NOPASSWD:ALL' > /etc/sudoers.d/django && \
    # Set the correct permissions for the sudoers file
    chmod 0440 /etc/sudoers.d/django; \
  else \
    # For non-local environments, we simply create a system group and user for django
    addgroup --system django && \
    adduser --system --ingroup django django; \
  fi


# Use the user 'django' for file ownership
COPY --chown=django:django . ${APP_HOME}

ENTRYPOINT ["/entrypoint"]

# Use 'django' as the default user
USER django
