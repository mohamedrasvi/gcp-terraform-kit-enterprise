variable "project_id" {
  description = "The GCP project ID where the Cloud DNS managed zone will be created."
  type        = string
}

variable "zone_name" {
  description = "The name of the managed DNS zone resource. Must be lowercase letters, numbers, and hyphens only."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,61}[a-z0-9]$", var.zone_name))
    error_message = "zone_name must be lowercase, start with a letter, and be 2-63 characters."
  }
}

variable "dns_name" {
  description = "The DNS name of the managed zone (e.g. 'example.com.'). Must end with a period."
  type        = string

  validation {
    condition     = can(regex("\\.$", var.dns_name))
    error_message = "dns_name must end with a trailing period (e.g. 'example.com.')."
  }
}

variable "description" {
  description = "A human-readable description for the managed DNS zone."
  type        = string
  default     = ""
}

variable "visibility" {
  description = "The visibility of the zone. 'public' is accessible from the internet. 'private' is accessible only within specified VPC networks."
  type        = string
  default     = "private"

  validation {
    condition     = contains(["public", "private"], var.visibility)
    error_message = "visibility must be 'public' or 'private'."
  }
}

variable "private_visibility_networks" {
  description = "List of VPC network self-links for zones with 'private' visibility. Required when visibility is 'private'."
  type        = list(string)
  default     = []
}

variable "enable_dnssec" {
  description = "Whether to enable DNSSEC for public zones. Adds cryptographic signatures to DNS responses."
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "Whether to enable Cloud DNS query logging for audit and security purposes."
  type        = bool
  default     = true
}

variable "labels" {
  description = "Key-value labels for the managed DNS zone."
  type        = map(string)
  default     = {}
}

variable "record_sets" {
  description = <<-EOT
    List of DNS record set configuration objects. Each object has:
    - name    (required) string: The DNS name of the record set (must be within the zone, e.g. 'www.example.com.').
    - type    (required) string: Record type (A, AAAA, CNAME, MX, TXT, NS, PTR, SRV, CAA, etc.).
    - rrdatas (required) list(string): The list of resource record data.
    - ttl     (optional) number: Time-to-live in seconds (default: 300).
  EOT
  type = list(object({
    name    = string
    type    = string
    rrdatas = list(string)
    ttl     = optional(number, 300)
  }))
  default = []
}
