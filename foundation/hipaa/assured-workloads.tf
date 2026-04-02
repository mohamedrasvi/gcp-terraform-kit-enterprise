# ===========================================================================
# foundation/hipaa/assured-workloads.tf
#
# Creates an Assured Workload per environment to enforce the selected
# compliance regime (default: HIPAA). Assured Workloads manages its own
# folder hierarchy; the folder IDs it returns are used downstream for
# project creation, networking, and monitoring.
# ===========================================================================

module "assured_workloads" {
  for_each = var.environments
  source   = "../../modules/assured-workloads"

  organization_id    = var.org_id
  display_name       = "${each.value.folder_display_name} (${var.compliance_regime})"
  compliance_regime  = var.compliance_regime
  location           = var.assured_workloads_location
  billing_account    = var.billing_account

  labels = merge(var.labels, {
    environment        = each.key
    compliance-regime  = lower(var.compliance_regime)
  })
}
