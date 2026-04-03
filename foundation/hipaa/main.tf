# ===========================================================================
# foundation/hipaa/main.tf
#
# Thin wrapper for the HIPAA-compliant landing zone.
# Assured Workloads (in assured-workloads.tf) creates the compliance folder
# for each environment; this file delegates all shared project/VPC/
# monitoring/logging/firewall/state-bucket logic to foundation-core.
# HIPAA-specific additions (VPC Service Controls) are wired here.
# ===========================================================================

locals {
  # Folder IDs from Assured Workloads — one per environment.
  env_folder_numeric_ids = {
    for env_key, aw in module.assured_workloads :
    env_key => trimprefix(aw.folder_id, "folders/")
  }
}

# ===========================================================================
# 1. Shared Landing-Zone Core (projects, VPC, monitoring, logging, buckets)
# ===========================================================================

module "foundation" {
  source = "../../modules/foundation-core"

  env_folder_numeric_ids         = local.env_folder_numeric_ids
  billing_account                = var.billing_account
  vpc_mode                       = var.vpc_mode
  shared_vpc_config              = var.shared_vpc_config
  non_shared_vpc_config          = var.non_shared_vpc_config
  enable_monitoring              = var.enable_monitoring
  enable_logging                 = var.enable_logging
  resource_state_bucket_location = var.resource_state_bucket_location
  labels                         = var.labels
  compliance_regime              = lower(var.compliance_regime)

  # HIPAA-specific APIs required for CMEK and VPC Service Controls
  extra_activate_apis = [
    "cloudkms.googleapis.com",
    "accesscontextmanager.googleapis.com",
  ]
}

# ===========================================================================
# 2. VPC Service Controls (HIPAA — prevents data exfiltration)
# ===========================================================================
# Requires: an existing Access Context Manager access policy at org level.
# Enable with: enable_vpc_service_controls = true and set access_policy_id.
# Start with vsc_dry_run = true to validate before enforcing.

module "vpc_service_controls" {
  for_each = var.enable_vpc_service_controls ? local.env_folder_numeric_ids : {}
  source   = "../../modules/vpc-service-controls"

  access_policy_id   = var.access_policy_id
  perimeter_name     = "hipaa_${replace(each.key, "-", "_")}"
  perimeter_title    = "HIPAA Perimeter — ${each.key}"
  dry_run            = var.vsc_dry_run
  protected_projects = module.foundation.project_numbers_by_env[each.key]
}
