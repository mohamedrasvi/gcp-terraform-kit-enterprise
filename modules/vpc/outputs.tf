output "network_id" {
  description = "The unique identifier of the VPC network."
  value       = google_compute_network.vpc.id
}

output "network_name" {
  description = "The name of the VPC network."
  value       = google_compute_network.vpc.name
}

output "network_self_link" {
  description = "The URI of the VPC network, used to reference it in other resources."
  value       = google_compute_network.vpc.self_link
}

output "gateway_ipv4" {
  description = "The gateway address for default routing out of the network."
  value       = google_compute_network.vpc.gateway_ipv4
}
