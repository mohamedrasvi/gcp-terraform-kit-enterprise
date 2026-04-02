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
  value       = local.aw_folder_ids
}

# ---------------------------------------------------------------------------
# Project IDs
# ---------------------------------------------------------------------------

output "project_ids" {
  description = "Map of '<env>/<project_id>' key to the GCP project ID."
  value = var.vpc_mode == "shared" ? merge(
    { for k, v in module.shared_common_project : k => v.project_id },
    { for k, v in module.shared_resource_project : k => v.project_id },
    ) : {
    for k, v in module.non_shared_project : k => v.project_id
  }
}

# ---------------------------------------------------------------------------
# Shared VPC host project IDs (shared mode only)
# ---------------------------------------------------------------------------

output "shared_vpc_host_project_ids" {
  description = "Map of environment key to the Shared VPC host (common) project ID. Empty in non-shared mode."
  value = var.vpc_mode == "shared" ? {
    for env_key, cfg in var.shared_vpc_config :
    env_key => cfg.common_project_id
  } : {}
}

# ---------------------------------------------------------------------------
# VPC self-links
# ---------------------------------------------------------------------------

output "vpc_self_links" {
  description = "Map of VPC network key to its self-link."
  value = var.vpc_mode == "shared" ? {
    for k, v in module.shared_vpc_network : k => v.network_self_link
    } : {
    for k, v in module.non_shared_vpc_network : k => v.network_self_link
  }
}

# ---------------------------------------------------------------------------
# Subnet self-links
# ---------------------------------------------------------------------------

output "subnet_self_links" {
  description = "Map of subnet key to its self-link."
  value = var.vpc_mode == "shared" ? merge(
    { for k, v in module.shared_public_subnets : k => v.subnet_self_link },
    { for k, v in module.shared_private_subnets : k => v.subnet_self_link },
    ) : merge(
    { for k, v in module.non_shared_public_subnets : k => v.subnet_self_link },
    { for k, v in module.non_shared_private_subnets : k => v.subnet_self_link },
  )
}

# ---------------------------------------------------------------------------
# GCS state bucket names (for resources layer)
# ---------------------------------------------------------------------------

output "state_bucket_names" {
  description = "Map of project ID to the GCS bucket name created for Terraform state storage in the resources layer."
  value = {
    for k, v in module.resource_state_buckets : k => v.bucket_name
  }
}
