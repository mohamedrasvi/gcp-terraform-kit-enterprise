terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}

# Cloud Router is required by Cloud NAT for BGP and route advertisement.
resource "google_compute_router" "router" {
  project     = var.project_id
  name        = var.router_name
  region      = var.region
  network     = var.network_self_link
  description = "Cloud Router for Cloud NAT in region ${var.region}"

  bgp {
    asn               = var.router_asn
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}

# Reserve static external IPs for NAT. Using static IPs instead of ephemeral
# ones allows firewall rules in downstream systems to allowlist NAT exit IPs.
resource "google_compute_address" "nat_ips" {
  count = var.nat_ip_count

  project      = var.project_id
  name         = "${var.nat_name}-ip-${count.index}"
  region       = var.region
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
  description  = "Static external IP ${count.index} for Cloud NAT ${var.nat_name}"
}

resource "google_compute_router_nat" "nat" {
  project                             = var.project_id
  name                                = var.nat_name
  router                              = google_compute_router.router.name
  region                              = var.region
  nat_ip_allocate_option              = var.nat_ip_count > 0 ? "MANUAL_ONLY" : "AUTO_ONLY"
  nat_ips                             = var.nat_ip_count > 0 ? google_compute_address.nat_ips[*].self_link : []
  source_subnetwork_ip_ranges_to_nat  = length(var.subnet_self_links) > 0 ? "LIST_OF_SUBNETWORKS" : "ALL_SUBNETWORKS_ALL_IP_RANGES"

  min_ports_per_vm                    = var.min_ports_per_vm
  tcp_established_idle_timeout_sec    = var.tcp_established_idle_timeout_sec
  tcp_transitory_idle_timeout_sec     = var.tcp_transitory_idle_timeout_sec
  udp_idle_timeout_sec                = var.udp_idle_timeout_sec
  icmp_idle_timeout_sec               = var.icmp_idle_timeout_sec
  enable_endpoint_independent_mapping = var.enable_endpoint_independent_mapping
  enable_dynamic_port_allocation      = var.enable_dynamic_port_allocation

  dynamic "subnetwork" {
    for_each = var.subnet_self_links
    content {
      name                    = subnetwork.value
      source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
    }
  }

  log_config {
    enable = var.enable_nat_logging
    filter = var.nat_log_filter
  }
}
