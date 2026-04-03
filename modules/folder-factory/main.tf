terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}

resource "google_folder" "folders" {
  for_each     = toset(var.names)
  display_name = each.value
  parent       = var.parent

  # Labels are not natively supported on google_folder; labels key is reserved
  # for organizational metadata managed externally or via tag bindings.
  # If future provider versions support labels, add: labels = var.labels
}

# Tag bindings require pre-created tag keys/values.
# To use, pass a map of {parent => tag_value} via a dedicated variable.
# Removed: previous implementation had a no-op for_each that always evaluated to {}.
