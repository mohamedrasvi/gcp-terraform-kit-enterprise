variable "parent" {
  description = "The resource name of the parent resource (organization or folder). Format: 'organizations/12345' or 'folders/12345'."
  type        = string

  validation {
    condition     = can(regex("^(organizations|folders)/[0-9]+$", var.parent))
    error_message = "Parent must be in the format 'organizations/<id>' or 'folders/<id>'."
  }
}

variable "names" {
  description = "List of folder display names to create under the specified parent."
  type        = list(string)

  validation {
    condition     = length(var.names) > 0
    error_message = "At least one folder name must be provided."
  }

  validation {
    condition     = alltrue([for n in var.names : length(n) >= 3 && length(n) <= 30])
    error_message = "Each folder display name must be between 3 and 30 characters."
  }
}

variable "labels" {
  description = "A map of key-value pairs to use as organizational metadata (applied via tag bindings where supported)."
  type        = map(string)
  default     = {}
}
