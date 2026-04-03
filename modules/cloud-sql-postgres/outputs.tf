output "instance_name" {
  description = "The name of the Cloud SQL instance (including random suffix)."
  value       = google_sql_database_instance.postgres.name
}

output "connection_name" {
  description = "The connection name of the instance used to connect with the Cloud SQL Proxy or connector libraries. Format: project:region:instance."
  value       = google_sql_database_instance.postgres.connection_name
}

output "private_ip_address" {
  description = "The private IP address of the Cloud SQL instance."
  value       = google_sql_database_instance.postgres.private_ip_address
  sensitive   = true
}

output "database_name" {
  description = "The name of the database created on the instance."
  value       = google_sql_database.database.name
}

output "instance_self_link" {
  description = "The server-defined URI for the Cloud SQL instance."
  value       = google_sql_database_instance.postgres.self_link
}

output "service_account_email" {
  description = "The service account email associated with the Cloud SQL instance."
  value       = google_sql_database_instance.postgres.service_account_email_address
}

