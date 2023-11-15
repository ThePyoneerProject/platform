variable "heroku_api_key" {
  description = "The API key for Heroku provider"
  type        = string
}

variable "django_allowed_hosts" {
  description = "Comma-separated list of hosts the Django site can serve"
  type        = string
}

variable "django_secret_key" {
  description = "The secret key used in the Django application for cryptographic signing"
  type        = string
}

variable "django_superuser_username" {
  description = "The username for the Django superuser"
  type        = string
}

variable "django_superuser_email" {
  description = "The email for the Django superuser"
  type        = string
}

variable "django_superuser_password" {
  description = "The password for the Django superuser"
  type        = string
}

variable "discord_bot_token" {
  description = "The token for the Discord bot"
  type        = string
}

variable "discord_guild_id" {
  description = "The ID of the Discord guild"
  type        = string
}

variable "discord_client_id" {
  description = "The client ID for Discord application"
  type        = string
}

variable "discord_client_secret" {
  description = "The client secret for Discord application"
  type        = string
}

variable "github_secret" {
  description = "The GitHub secret used for OAuth with GitHub"
  type        = string
}

variable "google_client_id" {
  description = "The client ID for Google authentication"
  type        = string
}

variable "google_client_secret" {
  description = "The client secret for Google authentication"
  type        = string
}

variable "sendgrid_api_key" {
  description = "API key for SendGrid"
  type        = string
}

variable "openai_api_key" {
  description = "API key for OpenAI services"
  type        = string
}

variable "sentry_dsn" {
  description = "DSN for Sentry monitoring"
  type        = string
}

variable "namecheap_user_name" {
  description = "Namecheap username"
  type        = string
}

variable "namecheap_api_user" {
  description = "Namecheap API user"
  type        = string
}

variable "namecheap_api_key" {
  description = "Namecheap API key"
  type        = string
}
