# ===========================================================================
# foundation/standard/org-policies.tf
#
# Applies baseline organisational policies at the organisation level.
# Domain-restricted sharing is configured using var.domain.
# ===========================================================================

locals {
  # The org-policies module accepts domain identifiers in the format
  # "is:domain:<domain>" for Google Workspace / Cloud Identity domains.
  domain_restricted_sharing_domains = var.domain != "" ? [
    "is:domain:${var.domain}"
  ] : []

  # Collect all env folder IDs so the module can also apply folder-level
  # reinforcement policies.
  all_env_folder_ids = [
    for env_key, env_cfg in var.environments :
    trimprefix(
      module.env_folders.folder_ids[env_cfg.folder_display_name],
      "folders/"
    )
  ]
}

module "org_policies" {
  source = "../../modules/org-policies"

  org_id     = var.org_id
  folder_ids = local.all_env_folder_ids

  # Boolean enforcement policies
  disable_serial_port                  = true
  disable_service_account_key_creation = true
  require_shielded_vm                  = true
  uniform_bucket_level_access          = true
  deny_vm_external_ip                  = false # Cloud NAT requires external IPs on the router

  # Domain restriction (allow only the organisation's own domain)
  domain_restricted_sharing_domains = local.domain_restricted_sharing_domains

  # No LB type restriction at this layer - leave open for resource configs
  allowed_load_balancer_types = []

  depends_on = [module.env_folders]
}
