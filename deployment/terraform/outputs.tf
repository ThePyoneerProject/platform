output "environment_type" {
  value       = heroku_app_config_association.app_config.vars.ENVIRONMENT_TYPE
  description = "The environment type of the deployed Django application on Heroku (e.g. staging, production)"
}

output "app_url" {
  value       = heroku_app.django-master.heroku_hostname
  description = "The URL of the deployed Django application on Heroku"
}

output "database_url" {
  value       = heroku_addon.postgres.config_var_values["DATABASE_URL"]
  description = "The DATABASE_URL for the Heroku Postgres addon"
  sensitive   = true
}

output "redis_url" {
  value       = heroku_addon.redis.config_var_values["REDIS_URL"]
  description = "The REDIS_URL for the Heroku Redis addon"
  sensitive   = true
}

