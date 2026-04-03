# ===========================================================================
# foundation/standard/main.tf
#
# Thin wrapper for the standard (non-HIPAA) landing zone.
# Creates environment folders via folder-factory, then delegates all
# project/VPC/monitoring/logging/firewall/state-bucket logic to the
# shared foundation-core module.
# ===========================================================================

locals {
  org_parent = "organizations/${var.org_id}"

  # Map environment key -> bare numeric folder ID (no "folders/" prefix)
  env_folder_numeric_ids = {
    for env_key, env_cfg in var.environments :
    env_key => trimprefix(
      module.env_folders.folder_ids[env_cfg.folder_display_name],
      "folders/"
    )
  }
}

# ===========================================================================
# 1. Environment Folders
# ===========================================================================

module "env_folders" {
  source = "../../modules/folder-factory"

  parent = local.org_parent
  names  = [for env_key, env_cfg in var.environments : env_cfg.folder_display_name]
  labels = var.labels
}

# ===========================================================================
# 2. Shared Landing-Zone Core (projects, VPC, monitoring, logging, buckets)
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
  compliance_regime              = "standard"
}
