terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}

resource "google_artifact_registry_repository" "repository" {
  project       = var.project_id
  location      = var.location
  repository_id = var.repository_id
  format        = var.format
  description   = var.description
  labels        = var.labels
  mode          = var.mode

  # Optional KMS encryption
  dynamic "docker_config" {
    for_each = var.format == "DOCKER" && var.docker_immutable_tags ? [1] : []
    content {
      immutable_tags = true
    }
  }

  dynamic "cleanup_policies" {
    for_each = var.cleanup_policies
    content {
      id     = cleanup_policies.key
      action = cleanup_policies.value.action

      dynamic "condition" {
        for_each = lookup(cleanup_policies.value, "condition", null) != null ? [cleanup_policies.value.condition] : []
        content {
          tag_state             = lookup(condition.value, "tag_state", null)
          tag_prefixes          = lookup(condition.value, "tag_prefixes", null)
          older_than            = lookup(condition.value, "older_than", null)
          newer_than            = lookup(condition.value, "newer_than", null)
          package_name_prefixes = lookup(condition.value, "package_name_prefixes", null)
          version_name_prefixes = lookup(condition.value, "version_name_prefixes", null)
        }
      }

      dynamic "most_recent_versions" {
        for_each = lookup(cleanup_policies.value, "most_recent_versions", null) != null ? [cleanup_policies.value.most_recent_versions] : []
        content {
          keep_count            = lookup(most_recent_versions.value, "keep_count", null)
          package_name_prefixes = lookup(most_recent_versions.value, "package_name_prefixes", null)
        }
      }
    }
  }

  dynamic "virtual_repository_config" {
    for_each = var.mode == "VIRTUAL_REPOSITORY" && length(var.upstream_policies) > 0 ? [1] : []
    content {
      dynamic "upstream_policies" {
        for_each = var.upstream_policies
        content {
          id         = upstream_policies.value.id
          repository = upstream_policies.value.repository
          priority   = upstream_policies.value.priority
        }
      }
    }
  }

  dynamic "remote_repository_config" {
    for_each = var.mode == "REMOTE_REPOSITORY" && var.remote_repository_upstream_url != null ? [1] : []
    content {
      description = "Remote repository proxying ${var.remote_repository_upstream_url}"
      docker_repository {
        custom_repository {
          uri = var.remote_repository_upstream_url
        }
      }
    }
  }
}

# Optional: IAM binding to restrict access
resource "google_artifact_registry_repository_iam_member" "readers" {
  for_each = toset(var.readers)

  project    = google_artifact_registry_repository.repository.project
  location   = google_artifact_registry_repository.repository.location
  repository = google_artifact_registry_repository.repository.name
  role       = "roles/artifactregistry.reader"
  member     = each.value
}

resource "google_artifact_registry_repository_iam_member" "writers" {
  for_each = toset(var.writers)

  project    = google_artifact_registry_repository.repository.project
  location   = google_artifact_registry_repository.repository.location
  repository = google_artifact_registry_repository.repository.name
  role       = "roles/artifactregistry.writer"
  member     = each.value
}
