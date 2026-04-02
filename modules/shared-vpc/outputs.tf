output "host_project_id" {
  description = "The project ID of the Shared VPC host project."
  value       = google_compute_shared_vpc_host_project.host.project
}

output "service_project_ids" {
  description = "The list of service project IDs attached to the Shared VPC host."
  value       = [for sp in google_compute_shared_vpc_service_project.service_projects : sp.service_project]
}

output "network_name" {
  description = "The name of the Shared VPC network (reference value passed in)."
  value       = var.network_name
}
