variable "project_id" {
  description = "The GCP project ID where subnets will be created."
  type        = string
}

variable "network_self_link" {
  description = "The self-link of the VPC network in which to create the subnets."
  type        = string
}

variable "subnets" {
  description = <<-EOT
    List of subnet configuration objects. Each object supports the following attributes:
    - name              (required) string: Subnet resource name.
    - region            (required) string: GCP region for the subnet.
    - ip_cidr_range     (required) string: Primary IPv4 CIDR range.
    - private_google_access (optional) bool: Enable Private Google Access (default: true).
    - is_public         (optional) bool: Informational flag indicating public subnet (no NAT enforcement here).
    - description       (optional) string: Human-readable description.
    - purpose           (optional) string: Subnet purpose, e.g. PRIVATE, INTERNAL_HTTPS_LOAD_BALANCER.
    - flow_logs_enabled (optional) bool: Enable VPC flow logs (default: true).
    - flow_logs_interval (optional) string: Flow log aggregation interval (default: INTERVAL_5_SEC).
    - flow_logs_sampling (optional) number: Flow log sampling rate 0.0-1.0 (default: 0.5).
    - flow_logs_metadata (optional) string: Flow log metadata (default: INCLUDE_ALL_METADATA).
    - secondary_ranges   (optional) list of objects with range_name and ip_cidr_range.
  EOT
  type = list(object({
    name                 = string
    region               = string
    ip_cidr_range        = string
    private_google_access = optional(bool, true)
    is_public            = optional(bool, false)
    description          = optional(string, "")
    purpose              = optional(string, "PRIVATE")
    flow_logs_enabled    = optional(bool, true)
    flow_logs_interval   = optional(string, "INTERVAL_5_SEC")
    flow_logs_sampling   = optional(number, 0.5)
    flow_logs_metadata   = optional(string, "INCLUDE_ALL_METADATA")
    secondary_ranges = optional(list(object({
      range_name    = string
      ip_cidr_range = string
    })), [])
  }))

  validation {
    condition     = length(var.subnets) > 0
    error_message = "At least one subnet must be specified."
  }
}
