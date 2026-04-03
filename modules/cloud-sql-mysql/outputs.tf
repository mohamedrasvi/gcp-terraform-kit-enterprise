output "instance_name" {
  description = "The name of the Cloud SQL MySQL instance (including random suffix)."
  value       = google_sql_database_instance.mysql.name
}

output "connection_name" {
  description = "The connection name for the instance used by Cloud SQL Auth Proxy or connector libraries. Format: project:region:instance."
  value       = google_sql_database_instance.mysql.connection_name
}

output "private_ip_address" {
  description = "The private IP address of the Cloud SQL MySQL instance."
  value       = google_sql_database_instance.mysql.private_ip_address
  sensitive   = true
}

output "database_name" {
  description = "The name of the database created on the instance."
  value       = google_sql_database.database.name
}

output "instance_self_link" {
  description = "The server-defined URI for the Cloud SQL instance."
  value       = google_sql_database_instance.mysql.self_link
}

output "service_account_email" {
  description = "The service account email associated with the Cloud SQL instance."
  value       = google_sql_database_instance.mysql.service_account_email_address
}

