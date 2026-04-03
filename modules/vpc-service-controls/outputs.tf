output "perimeter_name" {
  description = "The short name of the service perimeter."
  value       = google_access_context_manager_service_perimeter.perimeter.name
}

output "perimeter_id" {
  description = "The full resource ID of the service perimeter."
  value       = google_access_context_manager_service_perimeter.perimeter.id
}

output "dry_run_enabled" {
  description = "Whether the perimeter is in dry-run (spec) mode."
  value       = var.dry_run
}
