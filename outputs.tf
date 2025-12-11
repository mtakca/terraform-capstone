output "website_url" {
  description = "The public URL of the WordPress site"
  value       = "http://${module.alb.dns_name}"
}

output "database_endpoint" {
  description = "The database reader endpoint"
  value       = module.database.reader_endpoint
}
