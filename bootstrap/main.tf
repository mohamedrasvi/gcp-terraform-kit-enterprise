# Bootstrap: Creates the GCS bucket for Foundation Terraform state.
# This is run ONCE with local state, before anything else.
# After this, foundation/ can use this bucket as its backend.

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0.0"
    }
  }
  # Local state - this is intentional for bootstrap
}

provider "google" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {
  description = "GCP project ID to create the state bucket in (use your seed/admin project)"
  type        = string
}

variable "region" {
  description = "GCP region for the state bucket"
  type        = string
  default     = "us-central1"
}

variable "bucket_name" {
  description = "Name for the Terraform state bucket (must be globally unique)"
  type        = string
}

variable "labels" {
  description = "Labels to apply to the state bucket"
  type        = map(string)
  default     = { managed-by = "terraform-bootstrap" }
}

variable "terraform_sa_email" {
  description = "Email of the Terraform service account to grant objectAdmin on the bucket"
  type        = string
}

resource "google_storage_bucket" "tf_state" {
  name                        = var.bucket_name
  project                     = var.project_id
  location                    = var.region
  force_destroy               = false
  uniform_bucket_level_access = true
  labels                      = var.labels

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      num_newer_versions = 5
    }
  }
}

resource "google_storage_bucket_iam_member" "tf_state_admin" {
  bucket = google_storage_bucket.tf_state.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${var.terraform_sa_email}"
}

output "state_bucket_name" {
  description = "Name of the created GCS state bucket"
  value       = google_storage_bucket.tf_state.name
}

output "state_bucket_url" {
  description = "gs:// URL of the created GCS state bucket"
  value       = google_storage_bucket.tf_state.url
}
