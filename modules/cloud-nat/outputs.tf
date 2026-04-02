output "nat_id" {
  description = "The resource ID of the Cloud NAT gateway."
  value       = google_compute_router_nat.nat.id
}

output "router_id" {
  description = "The resource ID of the Cloud Router."
  value       = google_compute_router.router.id
}

output "router_name" {
  description = "The name of the Cloud Router."
  value       = google_compute_router.router.name
}

output "nat_name" {
  description = "The name of the Cloud NAT gateway."
  value       = google_compute_router_nat.nat.name
}

output "nat_ip_addresses" {
  description = "List of static external IP addresses allocated for NAT egress."
  value       = google_compute_address.nat_ips[*].address
}

output "nat_ip_self_links" {
  description = "List of self-links for static NAT IP addresses."
  value       = google_compute_address.nat_ips[*].self_link
}
