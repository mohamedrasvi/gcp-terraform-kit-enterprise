variable "project_id" {
  description = "The GCP project ID where the GCS bucket will be created."
  type        = string
}

variable "name" {
  description = "The globally unique name of the bucket. Must be 3-63 characters, lowercase, and DNS-compliant."
  type        = string
}

variable "location" {
  description = "The GCS bucket location. Can be a region (e.g. 'us-central1'), dual-region (e.g. 'US-CENTRAL1+US-EAST1'), or multi-region (e.g. 'US', 'EU', 'ASIA')."
  type        = string
}

variable "storage_class" {
  description = "The storage class for the bucket. STANDARD, NEARLINE, COLDLINE, or ARCHIVE."
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "MULTI_REGIONAL", "REGIONAL", "NEARLINE", "COLDLINE", "ARCHIVE"], var.storage_class)
    error_message = "storage_class must be one of: STANDARD, MULTI_REGIONAL, REGIONAL, NEARLINE, COLDLINE, ARCHIVE."
  }
}

variable "versioning_enabled" {
  description = "Whether to enable object versioning. Recommended for critical data."
  type        = bool
  default     = true
}

variable "uniform_bucket_level_access" {
  description = "Whether to enforce uniform bucket-level access (disables per-object ACLs). Required by org policy."
  type        = bool
  default     = true
}

variable "public_access_prevention" {
  description = "Prevents public access to the bucket. 'enforced' blocks all public access policies."
  type        = string
  default     = "enforced"

  validation {
    condition     = contains(["enforced", "inherited"], var.public_access_prevention)
    error_message = "public_access_prevention must be 'enforced' or 'inherited'."
  }
}

variable "force_destroy" {
  description = "When true, Terraform will delete all objects in the bucket before destroying the bucket. Use with extreme caution in production."
  type        = bool
  default     = false
}

variable "labels" {
  description = "Key-value labels to apply to the bucket."
  type        = map(string)
  default     = {}
}

variable "encryption_key" {
  description = "The Cloud KMS key name (self-link) to use for server-side encryption. Leave null to use Google-managed keys."
  type        = string
  default     = null
}

variable "lifecycle_rules" {
  description = <<-EOT
    List of lifecycle rule objects. Each has:
    - action: object with type ('Delete', 'SetStorageClass', 'AbortIncompleteMultipartUpload') and optional storage_class.
    - condition: object with optional age (days), created_before, with_state, matches_storage_class, num_newer_versions, days_since_noncurrent_time.
  EOT
  type = list(object({
    action = object({
      type          = string
      storage_class = optional(string)
    })
    condition = object({
      age                        = optional(number)
      created_before             = optional(string)
      with_state                 = optional(string)
      matches_storage_class      = optional(list(string))
      num_newer_versions         = optional(number)
      days_since_noncurrent_time = optional(number)
    })
  }))
  default = [
    {
      action    = { type = "Delete" }
      condition = { with_state = "ARCHIVED", num_newer_versions = 5 }
    },
    {
      action    = { type = "AbortIncompleteMultipartUpload" }
      condition = { age = 7 }
    }
  ]
}

variable "cors_rules" {
  description = "List of CORS configuration objects for the bucket."
  type = list(object({
    origin          = list(string)
    method          = list(string)
    response_header = optional(list(string), [])
    max_age_seconds = optional(number, 3600)
  }))
  default = []
}

variable "retention_policy_seconds" {
  description = "If set, the number of seconds objects must be retained in the bucket (retention lock). Use for compliance scenarios."
  type        = number
  default     = null
}

variable "retention_policy_locked" {
  description = "Whether the retention policy is locked. A locked policy cannot be reduced or removed."
  type        = bool
  default     = false
}

variable "access_log_bucket" {
  description = "Name of the GCS bucket to receive access logs. Leave null to disable access logging."
  type        = string
  default     = null
}

variable "access_log_prefix" {
  description = "Prefix for access log objects. Defaults to the bucket name if not set."
  type        = string
  default     = null
}
