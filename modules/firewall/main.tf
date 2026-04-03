terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

resource "google_compute_firewall" "rules" {
  for_each = { for rule in var.rules : rule.name => rule }

  project     = var.project_id
  network     = var.network_self_link
  name        = each.value.name
  description = lookup(each.value, "description", "")
  direction   = each.value.direction
  priority    = lookup(each.value, "priority", 1000)
  disabled    = lookup(each.value, "disabled", false)

  # Source/destination ranges
  source_ranges      = each.value.direction == "INGRESS" ? lookup(each.value, "ranges", []) : null
  destination_ranges = each.value.direction == "EGRESS" ? lookup(each.value, "ranges", []) : null

  # Optional tag-based targeting
  target_tags   = lookup(each.value, "target_tags", null)
  source_tags   = each.value.direction == "INGRESS" ? lookup(each.value, "source_tags", null) : null
  target_service_accounts = lookup(each.value, "target_service_accounts", null)
  source_service_accounts = each.value.direction == "INGRESS" ? lookup(each.value, "source_service_accounts", null) : null

  # Allow rules
  dynamic "allow" {
    for_each = lookup(each.value, "allow", [])
    content {
      protocol = allow.value.protocol
      ports    = lookup(allow.value, "ports", [])
    }
  }

  # Deny rules
  dynamic "deny" {
    for_each = lookup(each.value, "deny", [])
    content {
      protocol = deny.value.protocol
      ports    = lookup(deny.value, "ports", [])
    }
  }

  # Enable logging for audit trail
  dynamic "log_config" {
    for_each = lookup(each.value, "log_config_enabled", true) ? [1] : []
    content {
      metadata = lookup(each.value, "log_config_metadata", "INCLUDE_ALL_METADATA")
    }
  }
}
