output "instance_name" {
  description = "The name of the Cloud SQL MySQL instance (including random suffix)."
  value       = google_sql_database_instance.mysql.name
}

output "connection_name" {
  description = "The connection name for the instance used by Cloud SQL Auth Proxy or connector libraries. Format: project:region:instance."
  value       = google_sql_database_instance.mysql.connection_name
}

output "private_ip" {
  description = "The private IP address of the Cloud SQL MySQL instance."
  value       = google_sql_database_instance.mysql.private_ip_address
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

output "private_ip_range_name" {
  description = "The name of the reserved private IP range for the service networking connection."
  value       = google_compute_global_address.private_ip_range.name
}
