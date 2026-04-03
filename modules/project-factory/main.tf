terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

resource "google_project" "project" {
  name                = var.project_name
  project_id          = var.project_id
  folder_id           = var.folder_id
  billing_account     = var.billing_account
  labels              = var.labels
  auto_create_network = false

  lifecycle {
    prevent_destroy = false
  }
}

# Enable required APIs. disable_on_destroy = false ensures APIs remain
# enabled if the Terraform resource is removed, preventing accidental outages.
resource "google_project_service" "apis" {
  for_each = toset(var.activate_apis)

  project                    = google_project.project.project_id
  service                    = each.value
  disable_on_destroy         = false
  disable_dependent_services = false
}
