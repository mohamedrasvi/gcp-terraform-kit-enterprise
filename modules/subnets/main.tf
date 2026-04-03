terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

resource "google_compute_subnetwork" "subnets" {
  for_each = { for subnet in var.subnets : subnet.name => subnet }

  project                  = var.project_id
  network                  = var.network_self_link
  name                     = each.value.name
  region                   = each.value.region
  ip_cidr_range            = each.value.ip_cidr_range
  private_ip_google_access = each.value.private_google_access
  description              = lookup(each.value, "description", "")

  # Stack-type and purpose for Private Google Access compatibility
  purpose = lookup(each.value, "purpose", "PRIVATE")

  dynamic "secondary_ip_range" {
    for_each = lookup(each.value, "secondary_ranges", [])
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }

  # Log config for flow logs - enabled on all subnets for security compliance
  dynamic "log_config" {
    for_each = lookup(each.value, "flow_logs_enabled", true) ? [1] : []
    content {
      aggregation_interval = lookup(each.value, "flow_logs_interval", "INTERVAL_5_SEC")
      flow_sampling        = lookup(each.value, "flow_logs_sampling", 0.5)
      metadata             = lookup(each.value, "flow_logs_metadata", "INCLUDE_ALL_METADATA")
    }
  }
}
