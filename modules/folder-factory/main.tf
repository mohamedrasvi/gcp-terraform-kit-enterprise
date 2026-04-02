terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0.0"
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

resource "google_tags_tag_binding" "folder_labels" {
  for_each  = (var.labels != null && length(var.labels) > 0) ? {} : {}
  # Tag bindings require pre-created tag keys/values; left as extensibility hook.
  parent    = each.key
  tag_value = each.value
}
