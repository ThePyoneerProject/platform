# Create the Heroku app
resource "heroku_app" "staging" {
  name   = "django-staging"
  region = "eu"
  stack  = "container"
}

# Set the Heroku build
resource "heroku_build" "staging" {
  app_id = heroku_app.staging.id
  source {
    path = "../app"
  }
}

# Set the Heroku formation (dynos)
resource "heroku_formation" "staging" {
  app_id = heroku_app.staging.id
  type   = "web"
  quantity = 1
  size   = "Basic"

  depends_on = [
    heroku_build.staging,
    heroku_addon.staging_postgres,
    heroku_addon.staging_redis
  ]
}

# Set the config vars
resource "heroku_app_config_association" "staging" {
  app_id         = heroku_app.staging.id
  vars           = merge(local.common_vars, { ENVIRONMENT_TYPE = "staging" })
  sensitive_vars = local.sensitive_vars
}

# Create an AutoIdle addon
resource "heroku_addon" "auto_idle" {
  app_id = heroku_app.staging.id
  plan   = "autoidle:hobby"
}

# Create a Postgres addon
resource "heroku_addon" "staging_postgres" {
  app_id = heroku_app.staging.id
  plan   = "heroku-postgresql:mini"
}

# Create a Redis addon
resource "heroku_addon" "staging_redis" {
  app_id = heroku_app.staging.id
  plan   = "heroku-redis:mini"
}

# Create a custom domain in Heroku
resource "heroku_domain" "staging" {
  app_id   = heroku_app.staging.id
  hostname = "staging.pyoneers.dev"
}

# Configure Namecheap DNS records to point to the Heroku DNS target
resource "namecheap_domain_records" "staging" {
    domain = "pyoneers.dev"
    mode = "MERGE"

    record {
      hostname = "staging"
      type = "CNAME"
      address = "ssl.autoidleapp.com"  # This avoids Heroku from throwing errors when the app is idle
      ttl = 60
    }

  depends_on = [heroku_domain.staging]
}

# Add GitHub integration for deployment upon pushing to the `staging` branch
resource "herokux_app_github_integration" "staging" {
  app_id = heroku_app.staging.id
  branch = "staging"
  auto_deploy = true

  depends_on = [herokux_pipeline_github_integration.default]
}

# Add the staging app to the pipeline
resource "heroku_pipeline_coupling" "staging" {
  app_id    = heroku_app.staging.id
  pipeline  = heroku_pipeline.default.id
  stage     = "staging"
}
