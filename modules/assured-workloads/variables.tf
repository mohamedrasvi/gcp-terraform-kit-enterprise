variable "organization_id" {
  description = "The GCP organization ID in which to create the Assured Workload. Format: 'organizations/12345' or just the numeric ID."
  type        = string

  validation {
    condition     = can(regex("^(organizations/)?[0-9]+$", var.organization_id))
    error_message = "organization_id must be a numeric ID or 'organizations/<numeric-id>'."
  }
}

variable "display_name" {
  description = "The display name for the Assured Workloads workload."
  type        = string

  validation {
    condition     = length(var.display_name) >= 3 && length(var.display_name) <= 100
    error_message = "display_name must be between 3 and 100 characters."
  }
}

variable "location" {
  description = "The GCP location for the workload. For HIPAA this is typically 'us-central1' or 'us-east1'."
  type        = string
}

variable "compliance_regime" {
  description = <<-EOT
    The compliance regime for the workload. Common values:
    - HIPAA
    - HITRUST
    - FedRAMP_Moderate
    - FedRAMP_High
    - CJIS
    - IL2, IL4, IL5
    - ITAR
    - EU_REGIONS_AND_SUPPORT
  EOT
  type        = string
  default     = "HIPAA"

  validation {
    condition = contains([
      "HIPAA", "HITRUST", "ASSURED_WORKLOADS_FOR_PARTNERS",
      "FedRAMP_Moderate", "FedRAMP_High", "CJIS", "IL2", "IL4", "IL5",
      "ITAR", "EU_REGIONS_AND_SUPPORT", "SOVEREIGNTY_CONTROLS", "UNKNOWN"
    ], var.compliance_regime)
    error_message = "compliance_regime must be a valid Assured Workloads compliance regime."
  }
}

variable "billing_account" {
  description = "The billing account ID to associate with the workload resources (format: 'XXXXXX-XXXXXX-XXXXXX')."
  type        = string

  validation {
    condition     = can(regex("^[A-Z0-9]{6}-[A-Z0-9]{6}-[A-Z0-9]{6}$", var.billing_account))
    error_message = "billing_account must be in the format 'XXXXXX-XXXXXX-XXXXXX'."
  }
}

variable "labels" {
  description = "Key-value labels to apply to the workload and its provisioned resources."
  type        = map(string)
  default     = {}
}

variable "resource_settings" {
  description = <<-EOT
    List of resource settings for workload provisioning. Each object has:
    - resource_type (required) string: The resource type. One of:
        CONSUMER_PROJECT, ENCRYPTION_KEYS_PROJECT, KEYRING, CONSUMER_FOLDER.
    - resource_id   (optional) string: Pre-existing resource ID to use.
    - display_name  (optional) string: Display name for the auto-provisioned resource.
  EOT
  type = list(object({
    resource_type = string
    resource_id   = optional(string)
    display_name  = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for r in var.resource_settings : contains(
        ["CONSUMER_PROJECT", "ENCRYPTION_KEYS_PROJECT", "KEYRING", "CONSUMER_FOLDER"],
        r.resource_type
      )
    ])
    error_message = "Each resource_settings entry must have a valid resource_type."
  }
}

variable "kms_next_rotation_time" {
  description = "The timestamp (RFC3339 format) for the next scheduled KMS key rotation. Required if using CMEK. Example: '2024-01-01T00:00:00Z'."
  type        = string
  default     = null
}

variable "kms_rotation_period" {
  description = "The duration for KMS key rotation (e.g. '2592000s' for 30 days). Required when kms_next_rotation_time is set."
  type        = string
  default     = "7776000s" # 90 days
}
