# Heroku only supports amd64 architecture, so we need to specify the platform
FROM --platform=linux/amd64 python:3.11-slim-bullseye as builder

ARG BUILD_ENVIRONMENT=production

# Install build dependencies and psycopg2 dependencies in one layer to reduce image size
RUN apt-get update && apt-get install --no-install-recommends -y \
    # dependencies for building Python packages
    libpq-dev \
    # psycopg2 dependencies
    build-essential

# Requirements are installed here to ensure they will be cached.
COPY requirements .

# Create Python Dependency and Sub-Dependency Wheels.
RUN pip wheel --wheel-dir /usr/src/app/wheels  \
  -r ${BUILD_ENVIRONMENT}.txt

# Final stage
FROM --platform=linux/amd64 python:3.11-slim-bullseye

ARG BUILD_ENVIRONMENT=production
# Set the BUILD_ENVIRONMENT also as an environment variable (used in the start_django script)
ENV BUILD_ENVIRONMENT=${BUILD_ENVIRONMENT}

ARG APP_HOME=/app
ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1

WORKDIR ${APP_HOME}

# Install runtime dependencies, cleanup, and conditionally install additional libraries for local environment
RUN apt-get update && \
    apt-get install --no-install-recommends -y libpq-dev git && \
    if [ "$BUILD_ENVIRONMENT" = "local" ]; then \
        apt-get install --no-install-recommends -y sudo bash-completion nano ssh gettext; \
    fi && \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
    rm -rf /var/lib/apt/lists/*

# Create users depending on the BUILD_ENVIRONMENT
RUN if [ "$BUILD_ENVIRONMENT" = "local" ]; then \
        # Create a group and user with sudo access for local environment
        groupadd --gid 1000 django && \
        useradd --uid 1000 --gid django --shell /bin/bash --create-home django && \
        echo 'django ALL=(root) NOPASSWD:ALL' > /etc/sudoers.d/django && \
        chmod 0440 /etc/sudoers.d/django; \
    else \
        # Create a system group and user for non-local environments
        addgroup --system django && \
        adduser --system --ingroup django django; \
fi

# Copy the pre-built wheels from the builder stage
COPY --from=builder /usr/src/app/wheels /wheels/

# Install the python dependencies from the wheels
RUN pip install --no-cache-dir --no-index --find-links=/wheels/ /wheels/* \
    && rm -rf /wheels/

# Copy the entrypoint script and remove windows line endings
COPY --chown=django:django entrypoint /entrypoint
RUN sed -i 's/\r$//g' /entrypoint \
  && chmod +x /entrypoint

# Copy the start scripts and remove windows line endings
COPY --chown=django:django start_django /start_django
RUN sed -i 's/\r$//g' /start_django \
    && chmod +x /start_django

# Use the user 'django' for file ownership
COPY --chown=django:django . ${APP_HOME}

# Use 'django' as the default user
USER django

ENTRYPOINT ["/entrypoint"]

CMD ["/start_django"]
