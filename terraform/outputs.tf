# Production
output "app_production_url" {
  value       = heroku_app.production.heroku_hostname
  description = "The URL of the deployed Django application on Heroku (production)"
}
# Staging
output "app_staging_url" {
  value       = heroku_app.staging.heroku_hostname
  description = "The URL of the deployed Django application on Heroku (staging)"
}

output "staging_domain_dns_records" {
  # All record instances from namecheap_domain_records
    value       = namecheap_domain_records.staging.*
    description = "The DNS records to add to your domain to point to the staging application"
}

output "production_domain_dns_records" {
  # All record instances from namecheap_domain_records
  value       = namecheap_domain_records.production.*
  description = "The DNS records to add to your domain to point to the production application"
}

output "sendgrid_domain_dns_records" {
  value       = sendgrid_domain_authentication.default.dns
  description = "The DNS records to add to your domain to authenticate with SendGrid"
}
