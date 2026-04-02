variable "project_id" {
  description = "The GCP project ID where Cloud NAT and Cloud Router will be created."
  type        = string
}

variable "region" {
  description = "The GCP region in which to create the Cloud Router and Cloud NAT gateway."
  type        = string
}

variable "network_self_link" {
  description = "The self-link of the VPC network to associate with the Cloud Router."
  type        = string
}

variable "nat_name" {
  description = "The name for the Cloud NAT resource."
  type        = string
}

variable "router_name" {
  description = "The name for the Cloud Router resource."
  type        = string
}

variable "router_asn" {
  description = "The ASN (Autonomous System Number) for the Cloud Router's BGP configuration."
  type        = number
  default     = 64514
}

variable "subnet_self_links" {
  description = "List of subnet self-links that should have outbound internet access via this NAT. If empty, NAT applies to all subnets in the network."
  type        = list(string)
  default     = []
}

variable "nat_ip_count" {
  description = "Number of static external IP addresses to reserve for NAT. Set to 0 to use auto-allocated ephemeral IPs."
  type        = number
  default     = 1

  validation {
    condition     = var.nat_ip_count >= 0
    error_message = "nat_ip_count must be a non-negative integer."
  }
}

variable "min_ports_per_vm" {
  description = "Minimum number of ports allocated to a VM from the NAT IP. Increasing this reduces NAT port exhaustion but uses more IPs."
  type        = number
  default     = 64
}

variable "enable_dynamic_port_allocation" {
  description = "Enable dynamic port allocation, which scales port allocation up automatically based on load."
  type        = bool
  default     = true
}

variable "enable_endpoint_independent_mapping" {
  description = "Enable endpoint-independent mapping. When true, the same NAT IP and port is used for all connections from a VM to a given external endpoint."
  type        = bool
  default     = false
}

variable "tcp_established_idle_timeout_sec" {
  description = "Timeout (seconds) for TCP established connections. Default is 1200 (20 minutes)."
  type        = number
  default     = 1200
}

variable "tcp_transitory_idle_timeout_sec" {
  description = "Timeout (seconds) for TCP transitory connections (SYN-sent, SYN-rcvd). Default is 30 seconds."
  type        = number
  default     = 30
}

variable "udp_idle_timeout_sec" {
  description = "Timeout (seconds) for UDP streams. Default is 30 seconds."
  type        = number
  default     = 30
}

variable "icmp_idle_timeout_sec" {
  description = "Timeout (seconds) for ICMP mappings. Default is 30 seconds."
  type        = number
  default     = 30
}

variable "enable_nat_logging" {
  description = "Enable Cloud NAT logging for audit and troubleshooting purposes."
  type        = bool
  default     = true
}

variable "nat_log_filter" {
  description = "Specifies the desired filtering of logs on the NAT. Options: ALL, ERRORS_ONLY, TRANSLATIONS_ONLY."
  type        = string
  default     = "ERRORS_ONLY"

  validation {
    condition     = contains(["ALL", "ERRORS_ONLY", "TRANSLATIONS_ONLY"], var.nat_log_filter)
    error_message = "nat_log_filter must be one of: ALL, ERRORS_ONLY, TRANSLATIONS_ONLY."
  }
}
