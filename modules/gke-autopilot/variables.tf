variable "project_id" {
  description = "The GCP project ID in which to create the GKE Autopilot cluster."
  type        = string
}

variable "name" {
  description = "The name of the GKE Autopilot cluster."
  type        = string
}

variable "region" {
  description = "The GCP region for the GKE Autopilot cluster. Autopilot clusters are regional."
  type        = string
}

variable "network_self_link" {
  description = "The self-link of the VPC network for the cluster."
  type        = string
}

variable "subnet_self_link" {
  description = "The self-link of the subnetwork for the cluster nodes."
  type        = string
}

variable "pods_range_name" {
  description = "The name of the secondary IP range in the subnet to use for pod IP addresses."
  type        = string
}

variable "services_range_name" {
  description = "The name of the secondary IP range in the subnet to use for service cluster IPs."
  type        = string
}

variable "master_ipv4_cidr_block" {
  description = "The CIDR block for the GKE master (control plane) private endpoint. Must be /28 and not overlap with other ranges."
  type        = string
  default     = "172.16.0.0/28"
}

variable "enable_private_nodes" {
  description = "Whether to create nodes with only private IP addresses. Recommended for security."
  type        = bool
  default     = true
}

variable "enable_private_endpoint" {
  description = "Whether to disable the public endpoint of the cluster master. When true, the master is only accessible via the internal IP."
  type        = bool
  default     = false
}

variable "master_global_access_enabled" {
  description = "Whether the master's private endpoint is accessible from all Google Cloud regions and on-premises."
  type        = bool
  default     = true
}

variable "master_authorized_networks" {
  description = "List of CIDR blocks authorized to access the Kubernetes master API server."
  type = list(object({
    cidr_block   = string
    display_name = optional(string, "")
  }))
  default = []
}

variable "release_channel" {
  description = "The release channel for GKE cluster upgrades. REGULAR is recommended for production."
  type        = string
  default     = "REGULAR"

  validation {
    condition     = contains(["RAPID", "REGULAR", "STABLE", "UNSPECIFIED"], var.release_channel)
    error_message = "release_channel must be one of: RAPID, REGULAR, STABLE, UNSPECIFIED."
  }
}

variable "deletion_protection" {
  description = "Whether to prevent accidental cluster deletion via Terraform."
  type        = bool
  default     = true
}

variable "binary_authorization_mode" {
  description = "Binary Authorization evaluation mode. PROJECT_SINGLETON_POLICY_ENFORCE enforces project policy."
  type        = string
  default     = "PROJECT_SINGLETON_POLICY_ENFORCE"

  validation {
    condition     = contains(["DISABLED", "PROJECT_SINGLETON_POLICY_ENFORCE"], var.binary_authorization_mode)
    error_message = "binary_authorization_mode must be 'DISABLED' or 'PROJECT_SINGLETON_POLICY_ENFORCE'."
  }
}

variable "labels" {
  description = "Resource labels to apply to the GKE cluster."
  type        = map(string)
  default     = {}
}
