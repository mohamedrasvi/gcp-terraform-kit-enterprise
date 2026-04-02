variable "project_id" {
  description = "The GCP project ID in which to create the VPC network."
  type        = string
}

variable "network_name" {
  description = "The name of the VPC network to create. Must be lowercase, start with a letter, and contain only letters, numbers, and hyphens."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,62}[a-z0-9]$", var.network_name))
    error_message = "Network name must be lowercase, start with a letter, and be 2-64 characters."
  }
}

variable "description" {
  description = "An optional description for the VPC network."
  type        = string
  default     = ""
}

variable "routing_mode" {
  description = "The network-wide routing mode. REGIONAL routes learned by Cloud Routers are only advertised to the region. GLOBAL routes are advertised to all regions."
  type        = string
  default     = "GLOBAL"

  validation {
    condition     = contains(["REGIONAL", "GLOBAL"], var.routing_mode)
    error_message = "Routing mode must be either 'REGIONAL' or 'GLOBAL'."
  }
}

variable "delete_default_routes_on_create" {
  description = "If true, the default route (0.0.0.0/0 via default-internet-gateway) is deleted upon network creation. Recommended for private networks."
  type        = bool
  default     = false
}

variable "mtu" {
  description = "The network MTU in bytes. Must be between 1300 and 8896. Use 1500 for standard Ethernet, 8896 for Jumbo frames."
  type        = number
  default     = 1460

  validation {
    condition     = var.mtu >= 1300 && var.mtu <= 8896
    error_message = "MTU must be between 1300 and 8896."
  }
}
