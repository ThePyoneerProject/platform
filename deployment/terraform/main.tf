terraform {
  required_providers {
    heroku = {
      source  = "heroku/heroku"
    }
  }
}

# Configure the Heroku provider
provider "heroku" {
  api_key = var.heroku_api_key
}

# Create a new application
resource "heroku_app" "django-master" {
  name = "django-master"
  region = "eu"
  stack = "container"
}

# Define a Heroku Add-on for the database
resource "heroku_addon" "postgres" {
  app_id = heroku_app.django-master.id
  plan = "heroku-postgresql:mini"
}

resource "heroku_addon" "redis" {
  app_id = heroku_app.django-master.id
  plan = "heroku-redis:mini"
}

# Optionally, you can also configure environment variables for your Heroku app
resource "heroku_app_config_association" "app_config" {
  app_id = heroku_app.django-master.id

  vars = {
    DJANGO_SETTINGS_MODULE = "config.settings.production"
    ENVIRONMENT_TYPE      = "staging"
    DJANGO_ALLOWED_HOSTS  = var.django_allowed_hosts
    DJANGO_SECRET_KEY     = var.django_secret_key
    DJANGO_SUPERUSER_NAME = var.django_superuser_name
    DJANGO_SUPERUSER_EMAIL = var.django_superuser_email
    DJANGO_SUPERUSER_PASSWORD = var.django_superuser_password
  }

  sensitive_vars = {
    DISCORD_BOT_TOKEN     = var.discord_bot_token
    DISCORD_GUILD_ID      = var.discord_guild_id
    DISCORD_CLIENT_ID     = var.discord_client_id
    DISCORD_CLIENT_SECRET = var.discord_client_secret
    GITHUB_SECRET         = var.github_secret
    GOOGLE_CLIENT_ID      = var.google_client_id
    GOOGLE_CLIENT_SECRET  = var.google_client_secret
    MAILGUN_API_KEY       = var.mailgun_api_key
    MAILGUN_API_URL       = var.mailgun_api_url
    MAILGUN_DOMAIN        = var.mailgun_domain
    OPENAI_API_KEY        = var.openai_api_key
    SENTRY_DSN            = var.sentry_dsn
  }
}
