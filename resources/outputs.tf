# ---------------------------------------------------------------------------
# GKE Autopilot outputs
# ---------------------------------------------------------------------------

output "gke_autopilot_cluster_name" {
  description = "Name of the GKE Autopilot cluster"
  value       = var.enable_gke_autopilot ? module.gke_autopilot[0].cluster_name : null
}

output "gke_autopilot_cluster_endpoint" {
  description = "Endpoint of the GKE Autopilot cluster"
  value       = var.enable_gke_autopilot ? module.gke_autopilot[0].cluster_endpoint : null
  sensitive   = true
}

output "gke_autopilot_cluster_ca_certificate" {
  description = "CA certificate of the GKE Autopilot cluster"
  value       = var.enable_gke_autopilot ? module.gke_autopilot[0].cluster_ca_certificate : null
  sensitive   = true
}

# ---------------------------------------------------------------------------
# GKE Standard outputs
# ---------------------------------------------------------------------------

output "gke_self_managed_cluster_name" {
  description = "Name of the GKE Standard cluster"
  value       = var.enable_gke_self_managed ? module.gke_self_managed[0].cluster_name : null
}

output "gke_self_managed_cluster_endpoint" {
  description = "Endpoint of the GKE Standard cluster"
  value       = var.enable_gke_self_managed ? module.gke_self_managed[0].cluster_endpoint : null
  sensitive   = true
}

output "gke_self_managed_cluster_ca_certificate" {
  description = "CA certificate of the GKE Standard cluster"
  value       = var.enable_gke_self_managed ? module.gke_self_managed[0].cluster_ca_certificate : null
  sensitive   = true
}

# ---------------------------------------------------------------------------
# Cloud SQL PostgreSQL outputs
# ---------------------------------------------------------------------------

output "cloud_sql_postgres_instance_name" {
  description = "Name of the Cloud SQL PostgreSQL instance"
  value       = var.enable_cloud_sql_postgres ? module.cloud_sql_postgres[0].instance_name : null
}

output "cloud_sql_postgres_connection_name" {
  description = "Connection name of the Cloud SQL PostgreSQL instance (project:region:instance)"
  value       = var.enable_cloud_sql_postgres ? module.cloud_sql_postgres[0].connection_name : null
}

output "cloud_sql_postgres_private_ip" {
  description = "Private IP address of the Cloud SQL PostgreSQL instance"
  value       = var.enable_cloud_sql_postgres ? module.cloud_sql_postgres[0].private_ip_address : null
}

# ---------------------------------------------------------------------------
# Cloud SQL MySQL outputs
# ---------------------------------------------------------------------------

output "cloud_sql_mysql_instance_name" {
  description = "Name of the Cloud SQL MySQL instance"
  value       = var.enable_cloud_sql_mysql ? module.cloud_sql_mysql[0].instance_name : null
}

output "cloud_sql_mysql_connection_name" {
  description = "Connection name of the Cloud SQL MySQL instance (project:region:instance)"
  value       = var.enable_cloud_sql_mysql ? module.cloud_sql_mysql[0].connection_name : null
}

output "cloud_sql_mysql_private_ip" {
  description = "Private IP address of the Cloud SQL MySQL instance"
  value       = var.enable_cloud_sql_mysql ? module.cloud_sql_mysql[0].private_ip_address : null
}

# ---------------------------------------------------------------------------
# VM instance outputs
# ---------------------------------------------------------------------------

output "vm_instance_names" {
  description = "Names of the created VM instances"
  value       = var.enable_vm_instances ? { for k, v in module.vm_instances : k => v.instance_name } : {}
}

output "vm_instance_internal_ips" {
  description = "Internal IP addresses of the created VM instances"
  value       = var.enable_vm_instances ? { for k, v in module.vm_instances : k => v.internal_ip } : {}
}

output "vm_instance_self_links" {
  description = "Self-links of the created VM instances"
  value       = var.enable_vm_instances ? { for k, v in module.vm_instances : k => v.self_link } : {}
}

# ---------------------------------------------------------------------------
# GCS bucket outputs
# ---------------------------------------------------------------------------

output "gcs_bucket_names" {
  description = "Names of the created GCS buckets"
  value       = var.enable_gcs_buckets ? { for k, v in module.gcs_buckets : k => v.bucket_name } : {}
}

output "gcs_bucket_urls" {
  description = "gs:// URLs of the created GCS buckets"
  value       = var.enable_gcs_buckets ? { for k, v in module.gcs_buckets : k => v.bucket_url } : {}
}

# ---------------------------------------------------------------------------
# Artifact Registry outputs
# ---------------------------------------------------------------------------

output "artifact_registry_repository_id" {
  description = "Full resource ID of the Artifact Registry repository"
  value       = var.enable_artifact_registry ? module.artifact_registry[0].repository_id : null
}

output "artifact_registry_repository_url" {
  description = "URL of the Artifact Registry repository (e.g. for docker push)"
  value       = var.enable_artifact_registry ? module.artifact_registry[0].repository_url : null
}

# ---------------------------------------------------------------------------
# Cloud DNS outputs
# ---------------------------------------------------------------------------

output "cloud_dns_zone_name" {
  description = "Name of the Cloud DNS managed zone"
  value       = var.enable_cloud_dns ? module.cloud_dns[0].zone_name : null
}

output "cloud_dns_name_servers" {
  description = "Name servers for the Cloud DNS managed zone"
  value       = var.enable_cloud_dns ? module.cloud_dns[0].name_servers : null
}

# ---------------------------------------------------------------------------
# BigQuery outputs
# ---------------------------------------------------------------------------

output "bigquery_dataset_id" {
  description = "ID of the BigQuery dataset"
  value       = var.enable_bigquery ? module.bigquery[0].dataset_id : null
}

output "bigquery_dataset_self_link" {
  description = "Self-link of the BigQuery dataset"
  value       = var.enable_bigquery ? module.bigquery[0].dataset_self_link : null
}

output "bigquery_table_ids" {
  description = "IDs of the created BigQuery tables"
  value       = var.enable_bigquery ? module.bigquery[0].table_ids : null
}
