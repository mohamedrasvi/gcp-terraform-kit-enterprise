output "subnet_ids" {
  description = "Map of subnet name to subnet resource ID."
  value = {
    for name, subnet in google_compute_subnetwork.subnets :
    name => subnet.id
  }
}

output "subnet_self_links" {
  description = "Map of subnet name to subnet self-link URI."
  value = {
    for name, subnet in google_compute_subnetwork.subnets :
    name => subnet.self_link
  }
}

output "subnet_names" {
  description = "List of all subnet names created by this module."
  value       = [for subnet in google_compute_subnetwork.subnets : subnet.name]
}

output "subnet_regions" {
  description = "Map of subnet name to its GCP region."
  value = {
    for name, subnet in google_compute_subnetwork.subnets :
    name => subnet.region
  }
}

output "subnet_cidr_ranges" {
  description = "Map of subnet name to its primary CIDR range."
  value = {
    for name, subnet in google_compute_subnetwork.subnets :
    name => subnet.ip_cidr_range
  }
}
