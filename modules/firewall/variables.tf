variable "project_id" {
  description = "The GCP project ID where firewall rules will be created."
  type        = string
}

variable "network_self_link" {
  description = "The self-link of the VPC network to which the firewall rules will be applied."
  type        = string
}

variable "rules" {
  description = <<-EOT
    List of firewall rule configuration objects. Each object supports:
    - name                    (required) string: Unique firewall rule name.
    - direction               (required) string: INGRESS or EGRESS.
    - ranges                  (required) list(string): Source ranges (INGRESS) or destination ranges (EGRESS).
    - allow                   (optional) list(object): List of {protocol, ports} to allow.
    - deny                    (optional) list(object): List of {protocol, ports} to deny.
    - priority                (optional) number: Rule priority 0-65535 (lower = higher priority, default: 1000).
    - description             (optional) string: Human-readable description.
    - target_tags             (optional) list(string): Only applies to VMs with these network tags.
    - source_tags             (optional) list(string): INGRESS: traffic from VMs with these tags (overrides source_ranges).
    - target_service_accounts (optional) list(string): Only applies to VMs running as these SAs.
    - source_service_accounts (optional) list(string): INGRESS: traffic from VMs running as these SAs.
    - disabled                (optional) bool: If true, the rule is disabled.
    - log_config_enabled      (optional) bool: Enable firewall logging (default: true).
    - log_config_metadata     (optional) string: INCLUDE_ALL_METADATA or EXCLUDE_ALL_METADATA.
  EOT
  type = list(object({
    name                    = string
    direction               = string
    ranges                  = optional(list(string), [])
    priority                = optional(number, 1000)
    description             = optional(string, "")
    disabled                = optional(bool, false)
    target_tags             = optional(list(string))
    source_tags             = optional(list(string))
    target_service_accounts = optional(list(string))
    source_service_accounts = optional(list(string))
    log_config_enabled      = optional(bool, true)
    log_config_metadata     = optional(string, "INCLUDE_ALL_METADATA")
    allow = optional(list(object({
      protocol = string
      ports    = optional(list(string), [])
    })), [])
    deny = optional(list(object({
      protocol = string
      ports    = optional(list(string), [])
    })), [])
  }))
  default = []

  validation {
    condition = alltrue([
      for r in var.rules : contains(["INGRESS", "EGRESS"], r.direction)
    ])
    error_message = "Each rule's direction must be either 'INGRESS' or 'EGRESS'."
  }

  validation {
    condition = alltrue([
      for r in var.rules : length(r.allow) > 0 || length(r.deny) > 0
    ])
    error_message = "Each firewall rule must have at least one 'allow' or 'deny' block."
  }
}
