variable "project_id" {
  description = "The GCP project ID in which to create the GKE Standard cluster."
  type        = string
}

variable "name" {
  description = "The name of the GKE Standard cluster."
  type        = string
}

variable "region" {
  description = "The GCP region for the cluster. Regional clusters spread nodes across multiple zones."
  type        = string
}

variable "network_self_link" {
  description = "The self-link of the VPC network for the cluster."
  type        = string
}

variable "subnet_self_link" {
  description = "The self-link of the subnetwork for cluster nodes."
  type        = string
}

variable "pods_range_name" {
  description = "The name of the secondary IP range in the subnet for pod IP addresses."
  type        = string
}

variable "services_range_name" {
  description = "The name of the secondary IP range in the subnet for service cluster IPs."
  type        = string
}

variable "master_ipv4_cidr_block" {
  description = "The CIDR block (/28) for the GKE master private endpoint."
  type        = string
  default     = "172.16.0.0/28"
}

variable "enable_private_nodes" {
  description = "Whether to create nodes with only private IP addresses."
  type        = bool
  default     = true
}

variable "enable_private_endpoint" {
  description = "Whether to disable the public endpoint. When true, access to master is via the internal IP only."
  type        = bool
  default     = false
}

variable "master_global_access_enabled" {
  description = "Whether the master's private endpoint is accessible from all regions."
  type        = bool
  default     = true
}

variable "master_authorized_networks" {
  description = "List of CIDR blocks authorized to access the Kubernetes master API."
  type = list(object({
    cidr_block   = string
    display_name = optional(string, "")
  }))
  default = []
}

variable "release_channel" {
  description = "The release channel for GKE cluster upgrades."
  type        = string
  default     = "REGULAR"

  validation {
    condition     = contains(["RAPID", "REGULAR", "STABLE", "UNSPECIFIED"], var.release_channel)
    error_message = "release_channel must be one of: RAPID, REGULAR, STABLE, UNSPECIFIED."
  }
}

variable "deletion_protection" {
  description = "Whether to prevent accidental cluster deletion."
  type        = bool
  default     = true
}

variable "binary_authorization_mode" {
  description = "Binary Authorization evaluation mode."
  type        = string
  default     = "PROJECT_SINGLETON_POLICY_ENFORCE"

  validation {
    condition     = contains(["DISABLED", "PROJECT_SINGLETON_POLICY_ENFORCE"], var.binary_authorization_mode)
    error_message = "binary_authorization_mode must be 'DISABLED' or 'PROJECT_SINGLETON_POLICY_ENFORCE'."
  }
}

variable "labels" {
  description = "Resource labels for the GKE cluster."
  type        = map(string)
  default     = {}
}

variable "node_pools" {
  description = <<-EOT
    List of node pool configuration objects. Each object supports:
    - name               (required) string: Node pool name.
    - machine_type       (required) string: GCE machine type (e.g. 'e2-standard-4').
    - min_count          (required) number: Minimum node count per zone for autoscaling.
    - max_count          (required) number: Maximum node count per zone for autoscaling.
    - disk_size_gb       (optional) number: Boot disk size in GB (default: 100).
    - disk_type          (optional) string: Boot disk type (default: 'pd-ssd').
    - image_type         (optional) string: Node image type (default: 'COS_CONTAINERD').
    - preemptible        (optional) bool: Use preemptible VMs (default: false).
    - spot               (optional) bool: Use Spot VMs (default: false).
    - service_account    (optional) string: Service account email for nodes.
    - oauth_scopes       (optional) list(string): OAuth scopes for nodes.
    - labels             (optional) map(string): Kubernetes node labels.
    - tags               (optional) list(string): GCE network tags.
    - metadata           (optional) map(string): Additional GCE instance metadata.
    - taints             (optional) list(object): Kubernetes node taints with key, value, effect.
    - auto_repair        (optional) bool: Enable auto-repair (default: true).
    - auto_upgrade       (optional) bool: Enable auto-upgrade (default: true).
    - max_surge          (optional) number: Max surge nodes during upgrade (default: 1).
    - max_unavailable    (optional) number: Max unavailable nodes during upgrade (default: 0).
    - location_policy    (optional) string: Autoscaling location policy (default: BALANCED).
    - initial_node_count (optional) number: Initial node count (defaults to min_count).
    - enable_secure_boot (optional) bool: Enable Shielded VM secure boot (default: true).
    - enable_integrity_monitoring (optional) bool: Enable Shielded VM integrity monitoring (default: true).
  EOT
  type = list(object({
    name                        = string
    machine_type                = string
    min_count                   = number
    max_count                   = number
    disk_size_gb                = optional(number, 100)
    disk_type                   = optional(string, "pd-ssd")
    image_type                  = optional(string, "COS_CONTAINERD")
    preemptible                 = optional(bool, false)
    spot                        = optional(bool, false)
    service_account             = optional(string, null)
    oauth_scopes                = optional(list(string), ["https://www.googleapis.com/auth/cloud-platform"])
    labels                      = optional(map(string), {})
    tags                        = optional(list(string), [])
    metadata                    = optional(map(string), {})
    initial_node_count          = optional(number, null)
    auto_repair                 = optional(bool, true)
    auto_upgrade                = optional(bool, true)
    max_surge                   = optional(number, 1)
    max_unavailable             = optional(number, 0)
    location_policy             = optional(string, "BALANCED")
    enable_secure_boot          = optional(bool, true)
    enable_integrity_monitoring = optional(bool, true)
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
  }))
  default = []

  validation {
    condition     = length(var.node_pools) > 0
    error_message = "At least one node pool must be specified."
  }
}
