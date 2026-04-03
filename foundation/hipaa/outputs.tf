# ===========================================================================
# foundation/hipaa/outputs.tf
# ===========================================================================

# ---------------------------------------------------------------------------
# Assured Workload IDs (HIPAA-specific)
# ---------------------------------------------------------------------------

output "assured_workload_ids" {
  description = "Map of environment key to the Assured Workload resource name."
  value = {
    for env_key, aw in module.assured_workloads :
    env_key => aw.workload_id
  }
}

# ---------------------------------------------------------------------------
# Folder IDs (from Assured Workloads)
# ---------------------------------------------------------------------------

output "folder_ids" {
  description = "Map of environment key to the GCP folder ID created by Assured Workloads (format: folders/<id>)."
  value = {
    for env_key, aw in module.assured_workloads :
    env_key => aw.folder_id
  }
}

# ---------------------------------------------------------------------------
# Project IDs
# ---------------------------------------------------------------------------

output "project_ids" {
  description = "Map of '<env>/<project_id>' key to the GCP project ID."
  value       = module.foundation.project_ids
}

# ---------------------------------------------------------------------------
# Shared VPC host project IDs (shared mode only)
# ---------------------------------------------------------------------------

output "shared_vpc_host_project_ids" {
  description = "Map of environment key to the Shared VPC host (common) project ID. Empty in non-shared mode."
  value       = module.foundation.shared_vpc_host_project_ids
}

# ---------------------------------------------------------------------------
# VPC self-links
# ---------------------------------------------------------------------------

output "vpc_self_links" {
  description = "Map of VPC network key to its self-link."
  value       = module.foundation.vpc_self_links
}

# ---------------------------------------------------------------------------
# Subnet self-links
# ---------------------------------------------------------------------------

output "subnet_self_links" {
  description = "Map of subnet key to its self-link."
  value       = module.foundation.subnet_self_links
}

# ---------------------------------------------------------------------------
# GCS state bucket names (for resources layer)
# ---------------------------------------------------------------------------

output "state_bucket_names" {
  description = "Map of project ID to the GCS bucket name created for Terraform state storage in the resources layer."
  value       = module.foundation.state_bucket_names
}
