variable "access_policy_id" {
  description = "The numeric ID of the existing org-level Access Context Manager access policy. Create with: gcloud access-context-manager policies create --organization=ORG_ID --title='HIPAA Policy'"
  type        = string

  validation {
    condition     = can(regex("^[0-9]+$", var.access_policy_id))
    error_message = "access_policy_id must be a numeric string (e.g. '1234567890')."
  }
}

variable "perimeter_name" {
  description = "The short name for the service perimeter resource (alphanumeric and underscores only)."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]{0,49}$", var.perimeter_name))
    error_message = "perimeter_name must start with a letter, contain only letters, numbers, and underscores, and be at most 50 characters."
  }
}

variable "perimeter_title" {
  description = "A human-readable title for the service perimeter."
  type        = string
}

variable "perimeter_type" {
  description = "The type of service perimeter: PERIMETER_TYPE_REGULAR (default) or PERIMETER_TYPE_BRIDGE."
  type        = string
  default     = "PERIMETER_TYPE_REGULAR"

  validation {
    condition     = contains(["PERIMETER_TYPE_REGULAR", "PERIMETER_TYPE_BRIDGE"], var.perimeter_type)
    error_message = "perimeter_type must be PERIMETER_TYPE_REGULAR or PERIMETER_TYPE_BRIDGE."
  }
}

variable "protected_projects" {
  description = "List of project resource names to include in the perimeter. Format: 'projects/PROJECT_NUMBER' (not project ID)."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for p in var.protected_projects : can(regex("^projects/[0-9]+$", p))])
    error_message = "Each entry in protected_projects must be in the format 'projects/PROJECT_NUMBER'."
  }
}

variable "restricted_services" {
  description = "List of GCP API services restricted by the perimeter. Requests to these services from outside the perimeter are denied."
  type        = list(string)
  default = [
    "storage.googleapis.com",
    "bigquery.googleapis.com",
    "sqladmin.googleapis.com",
    "container.googleapis.com",
    "secretmanager.googleapis.com",
    "cloudkms.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "pubsub.googleapis.com",
    "dataflow.googleapis.com",
  ]
}

variable "vpc_allowed_services" {
  description = "Services accessible from within the VPC perimeter. Only relevant when vpc_accessible_services.enable_restriction = true."
  type        = list(string)
  default     = ["RESTRICTED-SERVICES"]
}

variable "dry_run" {
  description = "When true, the perimeter is created in dry-run mode (spec instead of status). Use this to validate impact before enforcement. Set to false to enforce."
  type        = bool
  default     = true
}

variable "ingress_policies" {
  description = <<-EOT
    List of ingress policy objects allowing access into the perimeter from outside.
    Each object has:
    - from: { identity_type, identities (list), access_level_sources (list) }
    - to:   { resources (list), operations (list of { service_name, methods }) }
  EOT
  type = list(object({
    from = object({
      identity_type        = optional(string)
      identities           = optional(list(string), [])
      access_level_sources = optional(list(string), [])
    })
    to = object({
      resources  = optional(list(string), ["*"])
      operations = optional(list(object({
        service_name = string
        methods      = optional(list(string), [])
      })), [])
    })
  }))
  default = []
}

variable "egress_policies" {
  description = <<-EOT
    List of egress policy objects allowing access from inside the perimeter to outside.
    Each object has:
    - from: { identity_type, identities (list) }
    - to:   { resources (list), operations (list of { service_name, methods }) }
  EOT
  type = list(object({
    from = object({
      identity_type = optional(string)
      identities    = optional(list(string), [])
    })
    to = object({
      resources  = optional(list(string), ["*"])
      operations = optional(list(object({
        service_name = string
        methods      = optional(list(string), [])
      })), [])
    })
  }))
  default = []
}
