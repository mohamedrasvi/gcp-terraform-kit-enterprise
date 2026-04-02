output "repository_id" {
  description = "The repository ID of the Artifact Registry repository."
  value       = google_artifact_registry_repository.repository.repository_id
}

output "repository_name" {
  description = "The fully qualified resource name of the repository."
  value       = google_artifact_registry_repository.repository.name
}

output "repository_self_link" {
  description = "The name/self-link of the repository resource."
  value       = google_artifact_registry_repository.repository.id
}

output "repository_url" {
  description = "The base URL for pushing/pulling from this repository (e.g. for Docker: <location>-docker.pkg.dev/<project>/<repository>)."
  value       = "${var.location}-docker.pkg.dev/${var.project_id}/${var.repository_id}"
}

output "location" {
  description = "The location of the repository."
  value       = google_artifact_registry_repository.repository.location
}

output "format" {
  description = "The format of the repository."
  value       = google_artifact_registry_repository.repository.format
}
