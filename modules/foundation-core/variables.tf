variable "env_folder_numeric_ids" {
  description = "Map of environment key to bare numeric folder ID (no 'folders/' prefix). Derived from folder-factory (standard) or Assured Workloads (HIPAA) by the caller."
  type        = map(string)
}

variable "billing_account" {
  description = "The billing account ID to associate with all projects (format: XXXXXX-XXXXXX-XXXXXX)."
  type        = string
}

variable "vpc_mode" {
  description = "Networking mode: 'shared' creates a Shared VPC host project per environment; 'non-shared' creates a standalone VPC per project."
  type        = string

  validation {
    condition     = contains(["shared", "non-shared"], var.vpc_mode)
    error_message = "vpc_mode must be either 'shared' or 'non-shared'."
  }
}

variable "shared_vpc_config" {
  description = <<-EOT
    Per-environment Shared VPC configuration. Keys must match keys in env_folder_numeric_ids.
    Each entry defines the common/host project and a list of service projects, plus subnets.
  EOT
  type = map(object({
    common_project_name = string
    common_project_id   = string
    resource_projects = list(object({
      project_name = string
      project_id   = string
    }))
    public_subnets = list(object({
      name          = string
      region        = string
      ip_cidr_range = string
    }))
    private_subnets = list(object({
      name          = string
      region        = string
      ip_cidr_range = string
    }))
  }))
  default = {}
}

variable "non_shared_vpc_config" {
  description = <<-EOT
    Per-environment non-shared VPC configuration. Keys must match keys in env_folder_numeric_ids.
    Each entry contains a list of projects; each project gets its own VPC.
  EOT
  type = map(object({
    projects = list(object({
      project_name = string
      project_id   = string
      public_subnets = list(object({
        name          = string
        region        = string
        ip_cidr_range = string
      }))
      private_subnets = list(object({
        name          = string
        region        = string
        ip_cidr_range = string
      }))
    }))
  }))
  default = {}
}

variable "enable_monitoring" {
  description = "Whether to create Cloud Monitoring resources (workspaces/scopes)."
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "Whether to create Cloud Logging sinks and aggregated log buckets."
  type        = bool
  default     = true
}

variable "resource_state_bucket_location" {
  description = "GCS multi-region or region location for Terraform state buckets created for the resources layer."
  type        = string
  default     = "US"
}

variable "labels" {
  description = "Base labels to apply to all projects and buckets created by this module."
  type        = map(string)
  default     = {}
}

variable "extra_activate_apis" {
  description = "Additional GCP APIs to enable on every project beyond the baseline set. Use for compliance-specific APIs (e.g. cloudkms.googleapis.com for HIPAA)."
  type        = list(string)
  default     = []
}

variable "compliance_regime" {
  description = "Compliance regime label applied to state buckets (e.g. 'standard', 'hipaa'). Added as the 'compliance-regime' label."
  type        = string
  default     = "standard"
}
