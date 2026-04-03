terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}

resource "google_storage_bucket" "bucket" {
  project                     = var.project_id
  name                        = var.name
  location                    = var.location
  storage_class               = var.storage_class
  uniform_bucket_level_access = var.uniform_bucket_level_access
  force_destroy               = var.force_destroy
  labels                      = var.labels
  public_access_prevention    = var.public_access_prevention

  versioning {
    enabled = var.versioning_enabled
  }

  dynamic "encryption" {
    for_each = var.encryption_key != null ? [1] : []
    content {
      default_kms_key_name = var.encryption_key
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules
    content {
      action {
        type          = lifecycle_rule.value.action.type
        storage_class = lookup(lifecycle_rule.value.action, "storage_class", null)
      }
      condition {
        age                        = lookup(lifecycle_rule.value.condition, "age", null)
        created_before             = lookup(lifecycle_rule.value.condition, "created_before", null)
        with_state                 = lookup(lifecycle_rule.value.condition, "with_state", null)
        matches_storage_class      = lookup(lifecycle_rule.value.condition, "matches_storage_class", null)
        num_newer_versions         = lookup(lifecycle_rule.value.condition, "num_newer_versions", null)
        days_since_noncurrent_time = lookup(lifecycle_rule.value.condition, "days_since_noncurrent_time", null)
      }
    }
  }

  dynamic "cors" {
    for_each = var.cors_rules
    content {
      origin          = cors.value.origin
      method          = cors.value.method
      response_header = lookup(cors.value, "response_header", [])
      max_age_seconds = lookup(cors.value, "max_age_seconds", 3600)
    }
  }

  dynamic "retention_policy" {
    for_each = var.retention_policy_seconds != null ? [1] : []
    content {
      is_locked        = var.retention_policy_locked
      retention_period = var.retention_policy_seconds
    }
  }

  # Enable audit logging via IAM conditions; logging is managed separately via
  # the logging module. Configure access logs to a dedicated logging bucket.
  dynamic "logging" {
    for_each = var.access_log_bucket != null ? [1] : []
    content {
      log_bucket        = var.access_log_bucket
      log_object_prefix = var.access_log_prefix != null ? var.access_log_prefix : var.name
    }
  }
}
