variable "project_id" {
  description = "The GCP project ID where the private service connection will be created."
  type        = string
}

variable "name" {
  description = "A unique name prefix for the global address resource (e.g. the VPC or project name)."
  type        = string
}

variable "network_self_link" {
  description = "The self-link of the VPC network to peer with Google services."
  type        = string
}

variable "prefix_length" {
  description = "The prefix length of the IP range reserved for Google-managed services. /20 reserves 4096 IPs which is sufficient for multiple Cloud SQL instances."
  type        = number
  default     = 20

  validation {
    condition     = var.prefix_length >= 16 && var.prefix_length <= 29
    error_message = "prefix_length must be between 16 and 29."
  }
}
