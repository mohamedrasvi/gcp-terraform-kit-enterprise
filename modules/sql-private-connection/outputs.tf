output "connection_id" {
  description = "The ID of the private service networking connection."
  value       = google_service_networking_connection.private_vpc_connection.id
}

output "reserved_range_name" {
  description = "The name of the reserved global address range."
  value       = google_compute_global_address.private_ip_range.name
}

output "private_ip_range_address" {
  description = "The reserved IP range address."
  value       = google_compute_global_address.private_ip_range.address
}
