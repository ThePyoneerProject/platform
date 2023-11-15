# Provider Configuration

terraform {
  required_providers {
    heroku = {
      source  = "heroku/heroku"
    }
    herokux = {
      source = "davidji99/herokux"
      version = "1.3.4"
    }
    namecheap = {
      source = "namecheap/namecheap"
      version = ">= 2.0.0"
    }
    sendgrid = {
      source = "anna-money/sendgrid"
      version = "1.0.5"
    }
  }
}

# Heroku API credentials
provider "heroku" {
  api_key = var.heroku_api_key
}

# Namecheap API credentials
provider "namecheap" {
  user_name = var.namecheap_user_name
  api_user = var.namecheap_api_user
  api_key = var.namecheap_api_key
}

# Sendgrid API credentials
provider "sendgrid" {
  api_key = var.sendgrid_api_key
}

# Set up the Sendgrid domain authentication
resource "sendgrid_domain_authentication" "default" {
  domain = "pyoneers.dev"
  subdomain = "mail"
  is_default = true
  automatic_security = true
  valid = true
}

# Configure Namecheap DNS records for Sendgrid domain authentication
resource "namecheap_domain_records" "sendgrid" {
  domain = "pyoneers.dev"
  mode = "MERGE"

  # Manually define each record with dynamic data lookup
  record {
    hostname = "s1._domainkey"
    type     = "CNAME"
    # Dynamically fetch the address data
    address  = lookup({for d in sendgrid_domain_authentication.default.dns : d.host => d.data}, "s1._domainkey.pyoneers.dev", "")
    ttl = 60
  }

  record {
    hostname = "s2._domainkey"
    type     = "CNAME"
    # Dynamically fetch the address data
    address  = lookup({for d in sendgrid_domain_authentication.default.dns : d.host => d.data}, "s2._domainkey.pyoneers.dev", "")
    ttl = 60
  }

  record {
    hostname = "mail"
    type     = "CNAME"
    # Dynamically fetch the address data
    address  = lookup({for d in sendgrid_domain_authentication.default.dns : d.host => d.data}, "mail.pyoneers.dev", "")
    ttl = 60
  }

  depends_on = [sendgrid_domain_authentication.default]
}

# Create the pipeline.
resource "heroku_pipeline" "default" {
  name = "pipeline"
}

# Add the GitHub repository integration with the pipeline.
resource "herokux_pipeline_github_integration" "default" {
  pipeline_id = heroku_pipeline.default.id
  org_repo = "ThePyoneerProject/platform"
}


# Set the common variables for both the staging and production apps.
locals {
  common_vars = {
    DJANGO_SETTINGS_MODULE    = "config.settings.production"
    DJANGO_ALLOWED_HOSTS      = var.django_allowed_hosts
    DJANGO_SECRET_KEY         = var.django_secret_key
    DJANGO_SUPERUSER_USERNAME = var.django_superuser_username
    DJANGO_SUPERUSER_EMAIL    = var.django_superuser_email
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
    SENDGRID_API_KEY      = var.sendgrid_api_key
    OPENAI_API_KEY        = var.openai_api_key
    SENTRY_DSN            = var.sentry_dsn
  }
}