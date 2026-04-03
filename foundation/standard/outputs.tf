# ===========================================================================
# foundation/standard/outputs.tf
# ===========================================================================

output "folder_ids" {
  description = "Map of environment key to the GCP folder ID (format: folders/<id>)."
  value = {
    for env_key, env_cfg in var.environments :
    env_key => module.env_folders.folder_ids[env_cfg.folder_display_name]
  }
}

output "project_ids" {
  description = "Map of '<env>/<project_id>' key to the GCP project ID."
  value       = module.foundation.project_ids
}

output "shared_vpc_host_project_ids" {
  description = "Map of environment key to the Shared VPC host (common) project ID. Empty in non-shared mode."
  value       = module.foundation.shared_vpc_host_project_ids
}

output "vpc_self_links" {
  description = "Map of VPC network key to its self-link. Key is '<env>' (shared) or '<env>/<project_id>' (non-shared)."
  value       = module.foundation.vpc_self_links
}

output "subnet_self_links" {
  description = "Map of subnet key to its self-link."
  value       = module.foundation.subnet_self_links
}

output "state_bucket_names" {
  description = "Map of project ID to the GCS bucket name created for Terraform state storage in the resources layer."
  value       = module.foundation.state_bucket_names
}
