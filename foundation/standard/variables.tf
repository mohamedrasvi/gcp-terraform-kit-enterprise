variable "org_id" {
  description = "The numeric GCP organization ID."
  type        = string
}

variable "billing_account" {
  description = "The billing account ID to associate with all projects (format: XXXXXX-XXXXXX-XXXXXX)."
  type        = string
}

variable "domain" {
  description = "The organization domain used for domain-restricted sharing org policy (e.g. 'example.com')."
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

variable "default_region" {
  description = "Default GCP region for resources that require one."
  type        = string
  default     = "us-central1"
}

variable "environments" {
  description = "Map of environment name to environment configuration. Keys are environment names (e.g. 'non-prod', 'prod')."
  type = map(object({
    folder_display_name = string
  }))
}

# ---------------------------------------------------------------------------
# Shared VPC configuration (used when vpc_mode = "shared")
# ---------------------------------------------------------------------------

variable "shared_vpc_config" {
  description = <<-EOT
    Per-environment Shared VPC configuration. Keys must match keys in var.environments.
    Each entry defines the common/host project and a list of service projects that will
    be attached to the Shared VPC, as well as public and private subnets.
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

# ---------------------------------------------------------------------------
# Non-shared VPC configuration (used when vpc_mode = "non-shared")
# ---------------------------------------------------------------------------

variable "non_shared_vpc_config" {
  description = <<-EOT
    Per-environment non-shared VPC configuration. Keys must match keys in var.environments.
    Each entry contains a list of projects; each project gets its own VPC with its own
    public and private subnets.
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

# ---------------------------------------------------------------------------
# Feature flags
# ---------------------------------------------------------------------------

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
  description = "Labels to apply to all projects and buckets created by this configuration."
  type        = map(string)
  default     = {}
}
