# Create a production app
resource "heroku_app" "production" {
  name   = "django-production"
  region = "eu"
  stack  = "container"
}

# Set the build to the production app
resource "heroku_build" "production" {
  app_id = heroku_app.production.id
  source {
    path = "../app"
  }
}

# Create a heroku formation for the production app
resource "heroku_formation" "production" {
  app_id = heroku_app.production.id
  type   = "web"
  quantity = 1
  size   = "Basic"

  depends_on = [
    heroku_build.production,
    heroku_addon.production_postgres,
    heroku_addon.production_redis
  ]
}

# Set the config vars for the production app
resource "heroku_app_config_association" "production" {
  app_id         = heroku_app.production.id
  vars           = merge(local.common_vars, { ENVIRONMENT_TYPE = "production" })
  sensitive_vars = local.sensitive_vars
}

# Create a Postgres addon for the production app
resource "heroku_addon" "production_postgres" {
  app_id = heroku_app.production.id
  plan   = "heroku-postgresql:mini"

  lifecycle {
    prevent_destroy = true
  }
}

# Create a Redis addon for the production app
resource "heroku_addon" "production_redis" {
  app_id = heroku_app.production.id
  plan   = "heroku-redis:mini"
}

# Create custom domains in Heroku (non-www and www)
resource "heroku_domain" "production_non_www" {
  app_id   = heroku_app.production.id
  hostname = "pyoneers.dev"
}
resource "heroku_domain" "production_www" {
  app_id   = heroku_app.production.id
  hostname = "www.pyoneers.dev"
}

# Configure Namecheap DNS records to point to the Heroku DNS target
resource "namecheap_domain_records" "production" {
    domain = "pyoneers.dev"
    mode = "MERGE"

    record {
      hostname = "@"
      type = "ALIAS"
      address = heroku_domain.production_non_www.cname
      ttl = 60
    }

    record {
      hostname = "www"
      type = "CNAME"
      address = heroku_domain.production_www.cname
      ttl = 60
    }

  # Ensure DNS records are set after the Heroku domain is created
  depends_on = [heroku_domain.production_non_www, heroku_domain.production_www]
}

# Add Heroku app GitHub integration.
resource "herokux_app_github_integration" "production" {
  app_id = heroku_app.production.id
  branch = "production"
  auto_deploy = true

  # Tells Terraform that this resource must be created/updated
  # only after the `herokux_pipeline_github_integration` has been successfully applied.
  depends_on = [herokux_pipeline_github_integration.default]
}

# Add the production app to the pipeline
resource "heroku_pipeline_coupling" "production" {
  app_id    = heroku_app.production.id
  pipeline  = heroku_pipeline.default.id
  stage     = "production"
}
