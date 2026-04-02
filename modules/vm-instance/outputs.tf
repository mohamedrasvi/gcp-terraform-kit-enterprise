output "instance_id" {
  description = "The server-assigned unique ID for the Compute Engine instance."
  value       = google_compute_instance.vm.instance_id
}

output "name" {
  description = "The name of the Compute Engine instance."
  value       = google_compute_instance.vm.name
}

output "self_link" {
  description = "The self-link URI of the instance."
  value       = google_compute_instance.vm.self_link
}

output "internal_ip" {
  description = "The internal (private) IP address of the instance."
  value       = google_compute_instance.vm.network_interface[0].network_ip
}

output "external_ip" {
  description = "The external IP address of the instance, if one was assigned."
  value       = var.enable_external_ip ? google_compute_instance.vm.network_interface[0].access_config[0].nat_ip : null
}

output "zone" {
  description = "The zone in which the instance was created."
  value       = google_compute_instance.vm.zone
}
