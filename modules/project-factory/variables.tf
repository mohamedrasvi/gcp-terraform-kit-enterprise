variable "project_name" {
  description = "The human-readable display name for the GCP project."
  type        = string

  validation {
    condition     = length(var.project_name) >= 4 && length(var.project_name) <= 30
    error_message = "Project name must be between 4 and 30 characters."
  }
}

variable "project_id" {
  description = "The unique project ID. Must be 6-30 characters, lowercase letters, digits, and hyphens only. Cannot start or end with a hyphen."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Project ID must be 6-30 characters, start with a lowercase letter, and contain only lowercase letters, digits, and hyphens."
  }
}

variable "folder_id" {
  description = "The numeric ID of the folder under which the project will be created. Do not include the 'folders/' prefix."
  type        = string
  default     = null
}

variable "billing_account" {
  description = "The alphanumeric billing account ID to associate with the project (e.g. '01A2B3-CD4E5F-6G7H8I')."
  type        = string

  validation {
    condition     = can(regex("^[A-Z0-9]{6}-[A-Z0-9]{6}-[A-Z0-9]{6}$", var.billing_account))
    error_message = "Billing account must be in the format 'XXXXXX-XXXXXX-XXXXXX'."
  }
}

variable "labels" {
  description = "A map of key-value labels to assign to the project for organizational and billing purposes."
  type        = map(string)
  default     = {}
}

variable "activate_apis" {
  description = "List of GCP API service names to enable on the project (e.g. 'compute.googleapis.com')."
  type        = list(string)
  default = [
    "compute.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "storage.googleapis.com",
  ]
}
