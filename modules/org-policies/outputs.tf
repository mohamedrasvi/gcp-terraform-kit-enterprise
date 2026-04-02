output "org_policy_names" {
  description = "Map of policy constraint names to their resource names applied at the organization level."
  value = merge(
    length(google_org_policy_policy.disable_serial_port) > 0 ? {
      "compute.disableSerialPortAccess" = google_org_policy_policy.disable_serial_port[0].name
    } : {},
    length(google_org_policy_policy.disable_sa_key_creation) > 0 ? {
      "iam.disableServiceAccountKeyCreation" = google_org_policy_policy.disable_sa_key_creation[0].name
    } : {},
    length(google_org_policy_policy.require_shielded_vm) > 0 ? {
      "compute.requireShieldedVm" = google_org_policy_policy.require_shielded_vm[0].name
    } : {},
    length(google_org_policy_policy.uniform_bucket_level_access) > 0 ? {
      "storage.uniformBucketLevelAccess" = google_org_policy_policy.uniform_bucket_level_access[0].name
    } : {},
    length(google_org_policy_policy.vm_external_ip_access) > 0 ? {
      "compute.vmExternalIpAccess" = google_org_policy_policy.vm_external_ip_access[0].name
    } : {},
    length(google_org_policy_policy.domain_restricted_sharing) > 0 ? {
      "iam.allowedPolicyMemberDomains" = google_org_policy_policy.domain_restricted_sharing[0].name
    } : {},
    length(google_org_policy_policy.restrict_lb_types) > 0 ? {
      "compute.restrictLoadBalancerCreationForTypes" = google_org_policy_policy.restrict_lb_types[0].name
    } : {},
  )
}

output "folder_policy_names" {
  description = "Map of folder parent to list of applied policy names."
  value = {
    for parent in toset([
      for k in keys(google_org_policy_policy.folder_disable_serial_port) : k
    ]) : parent => [
      try(google_org_policy_policy.folder_disable_serial_port[parent].name, null),
      try(google_org_policy_policy.folder_require_shielded_vm[parent].name, null),
      try(google_org_policy_policy.folder_vm_external_ip_access[parent].name, null),
    ]
  }
}
