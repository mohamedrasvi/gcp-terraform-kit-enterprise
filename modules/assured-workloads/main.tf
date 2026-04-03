terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}

resource "google_assured_workloads_workload" "workload" {
  display_name       = var.display_name
  location           = var.location
  organization       = var.organization_id
  compliance_regime  = var.compliance_regime
  billing_account    = var.billing_account
  labels             = var.labels

  # Provisioned resource settings allow pre-specifying project/folder structure
  # for the workload boundary. If not provided, GCP will auto-provision.
  dynamic "resource_settings" {
    for_each = var.resource_settings
    content {
      resource_type = resource_settings.value.resource_type
      resource_id   = lookup(resource_settings.value, "resource_id", null)
      display_name  = lookup(resource_settings.value, "display_name", null)
    }
  }

  # KMS settings for compliance-managed encryption keys (CMEK)
  dynamic "kms_settings" {
    for_each = var.kms_next_rotation_time != null ? [1] : []
    content {
      next_rotation_time = var.kms_next_rotation_time
      rotation_period    = var.kms_rotation_period
    }
  }
}
