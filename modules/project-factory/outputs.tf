output "project_id" {
  description = "The project ID of the created GCP project."
  value       = google_project.project.project_id
}

output "project_number" {
  description = "The numeric identifier of the created GCP project."
  value       = google_project.project.number
}

output "project_name" {
  description = "The display name of the created GCP project."
  value       = google_project.project.name
}

output "enabled_apis" {
  description = "The list of APIs enabled on this project."
  value       = [for svc in google_project_service.apis : svc.service]
}
