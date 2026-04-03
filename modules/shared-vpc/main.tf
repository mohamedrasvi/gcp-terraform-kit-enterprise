terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}

# Enable Shared VPC on the host project. This designates the project as the
# host, making its network available to service projects.
resource "google_compute_shared_vpc_host_project" "host" {
  project = var.host_project_id
}

# Attach each service project to the host project. Service projects can then
# use subnets from the host project's shared VPC network.
resource "google_compute_shared_vpc_service_project" "service_projects" {
  for_each = toset(var.service_project_ids)

  host_project    = google_compute_shared_vpc_host_project.host.project
  service_project = each.value
}
