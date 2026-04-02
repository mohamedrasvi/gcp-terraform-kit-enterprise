output "cluster_name" {
  description = "The name of the GKE Standard cluster."
  value       = google_container_cluster.cluster.name
}

output "cluster_id" {
  description = "The unique resource ID of the cluster."
  value       = google_container_cluster.cluster.id
}

output "cluster_endpoint" {
  description = "The IP address of the Kubernetes master API server."
  value       = google_container_cluster.cluster.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "The base64-encoded public certificate authority certificate for the cluster."
  value       = google_container_cluster.cluster.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "cluster_location" {
  description = "The region/zone of the cluster."
  value       = google_container_cluster.cluster.location
}

output "node_pool_names" {
  description = "List of node pool names created in this cluster."
  value       = [for pool in google_container_node_pool.node_pools : pool.name]
}

output "node_pool_instance_group_urls" {
  description = "Map of node pool name to list of managed instance group URLs."
  value = {
    for name, pool in google_container_node_pool.node_pools :
    name => pool.managed_instance_group_urls
  }
}

output "workload_identity_pool" {
  description = "The Workload Identity Pool for the cluster."
  value       = google_container_cluster.cluster.workload_identity_config[0].workload_pool
}
