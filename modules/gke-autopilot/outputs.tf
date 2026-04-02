output "cluster_name" {
  description = "The name of the GKE Autopilot cluster."
  value       = google_container_cluster.autopilot.name
}

output "cluster_id" {
  description = "The unique resource ID of the cluster."
  value       = google_container_cluster.autopilot.id
}

output "cluster_endpoint" {
  description = "The IP address of the Kubernetes master API server endpoint."
  value       = google_container_cluster.autopilot.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "The base64-encoded public certificate that is the root of trust for the cluster."
  value       = google_container_cluster.autopilot.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "cluster_location" {
  description = "The region of the cluster."
  value       = google_container_cluster.autopilot.location
}

output "workload_identity_pool" {
  description = "The Workload Identity Pool for the cluster, used to map Kubernetes service accounts to GCP service accounts."
  value       = google_container_cluster.autopilot.workload_identity_config[0].workload_pool
}
