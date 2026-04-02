variable "org_id" {
  description = "The numeric GCP organization ID to apply org-level policies to. Either org_id or folder_ids must be provided."
  type        = string
  default     = null
}

variable "folder_ids" {
  description = "List of folder IDs (without the 'folders/' prefix) to apply folder-level policies to."
  type        = list(string)
  default     = []
}

variable "disable_serial_port" {
  description = "Whether to enforce constraints/compute.disableSerialPortAccess (disables serial port access on all VMs)."
  type        = bool
  default     = true
}

variable "disable_service_account_key_creation" {
  description = "Whether to enforce constraints/iam.disableServiceAccountKeyCreation (prevents user-managed SA key creation)."
  type        = bool
  default     = true
}

variable "require_shielded_vm" {
  description = "Whether to enforce constraints/compute.requireShieldedVm (requires all VMs to use Shielded VM features)."
  type        = bool
  default     = true
}

variable "uniform_bucket_level_access" {
  description = "Whether to enforce constraints/storage.uniformBucketLevelAccess (requires uniform bucket-level access on all GCS buckets)."
  type        = bool
  default     = true
}

variable "deny_vm_external_ip" {
  description = "Whether to deny all external IP addresses for Compute Engine VMs via constraints/compute.vmExternalIpAccess."
  type        = bool
  default     = true
}

variable "domain_restricted_sharing_domains" {
  description = "List of identity domain identifiers (e.g. 'C0abc1def' or 'is:domain:example.com') allowed by constraints/iam.allowedPolicyMemberDomains. Empty list disables this policy."
  type        = list(string)
  default     = []
}

variable "allowed_load_balancer_types" {
  description = "List of allowed load balancer types for constraints/compute.restrictLoadBalancerCreationForTypes. Example: ['INTERNAL_TCP_UDP', 'INTERNAL_HTTP_HTTPS']. Empty list disables this policy."
  type        = list(string)
  default     = []
}
