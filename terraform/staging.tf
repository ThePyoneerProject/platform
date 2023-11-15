# Create a staging app
resource "heroku_app" "staging" {
  name   = "django-staging"
  region = "eu"
  stack  = "container"
}

# Associate a custom domain
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
      address = "ssl.autoidleapp.com"
      ttl = 60
    }

  # Ensure DNS records are set after the Heroku domain is created
  depends_on = [heroku_domain.staging]
}

# Add Heroku app GitHub integration.
resource "herokux_app_github_integration" "staging" {
  app_id = heroku_app.staging.id
  branch = "staging"
  auto_deploy = true

  # Tells Terraform that this resource must be created/updated
  # only after the `herokux_pipeline_github_integration` has been successfully applied.
  depends_on = [herokux_pipeline_github_integration.default]
}

# Create a heroku formation for the staging app
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

# Set the build to the staging app
resource "heroku_build" "staging" {
  app_id = heroku_app.staging.id
  source {
    path = "../app"
  }
}

# Create an AutoIdle addon for the staging app
resource "heroku_addon" "auto_idle" {
  app_id = heroku_app.staging.id
  plan   = "autoidle:hobby"
}

# Create a Postgres addon for the staging app
resource "heroku_addon" "staging_postgres" {
  app_id = heroku_app.staging.id
  plan   = "heroku-postgresql:mini"
}

# Create a Redis addon for the staging app
resource "heroku_addon" "staging_redis" {
  app_id = heroku_app.staging.id
  plan   = "heroku-redis:mini"
}

# Add the staging app to the pipeline
resource "heroku_pipeline_coupling" "staging" {
  app_id    = heroku_app.staging.id
  pipeline  = heroku_pipeline.default.id
  stage     = "staging"
}

# Set the config vars for the staging app
resource "heroku_app_config_association" "staging" {
  app_id         = heroku_app.staging.id
  vars           = merge(local.common_vars, { ENVIRONMENT_TYPE = "staging" })
  sensitive_vars = local.sensitive_vars
}
