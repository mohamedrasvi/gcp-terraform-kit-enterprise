terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

resource "google_dns_managed_zone" "zone" {
  project     = var.project_id
  name        = var.zone_name
  dns_name    = var.dns_name
  description = var.description
  labels      = var.labels

  visibility = var.visibility

  dynamic "private_visibility_config" {
    for_each = var.visibility == "private" ? [1] : []
    content {
      dynamic "networks" {
        for_each = var.private_visibility_networks
        content {
          network_url = networks.value
        }
      }
    }
  }

  # Enable DNSSEC for public zones
  dynamic "dnssec_config" {
    for_each = var.visibility == "public" && var.enable_dnssec ? [1] : []
    content {
      state         = "on"
      non_existence = "nsec3"

      default_key_specs {
        algorithm  = "rsasha256"
        key_length = 2048
        key_type   = "keySigning"
      }

      default_key_specs {
        algorithm  = "rsasha256"
        key_length = 1024
        key_type   = "zoneSigning"
      }
    }
  }

  # Enable logging for DNS queries (Security Command Center integration)
  dynamic "cloud_logging_config" {
    for_each = var.enable_logging ? [1] : []
    content {
      enable_logging = true
    }
  }
}

# DNS record sets
resource "google_dns_record_set" "records" {
  for_each = { for r in var.record_sets : "${r.name}-${r.type}" => r }

  project      = var.project_id
  managed_zone = google_dns_managed_zone.zone.name
  name         = each.value.name
  type         = each.value.type
  ttl          = lookup(each.value, "ttl", 300)
  rrdatas      = each.value.rrdatas
}
