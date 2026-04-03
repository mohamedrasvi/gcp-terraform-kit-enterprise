terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# ---------------------------------------------------------------------------
# Shared private service connection for Cloud SQL (and other Google services
# that use VPC peering via servicenetworking.googleapis.com).
#
# IMPORTANT: Only ONE google_service_networking_connection can exist per VPC
# network. Deploying multiple Cloud SQL instances (e.g. both Postgres and
# MySQL) in the same VPC must share this single connection. This module
# should be instantiated once per VPC, then its connection passed to every
# Cloud SQL module in that VPC.
# ---------------------------------------------------------------------------

resource "google_compute_global_address" "private_ip_range" {
  project       = var.project_id
  name          = "${var.name}-private-ip-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = var.prefix_length
  network       = var.network_self_link
  description   = "Private IP range for Google-managed services VPC peering in ${var.network_self_link}"
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = var.network_self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_range.name]

  lifecycle {
    # Deleting this connection while Cloud SQL instances exist will break them.
    prevent_destroy = true
  }
}
