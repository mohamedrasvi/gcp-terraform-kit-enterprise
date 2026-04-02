variable "project_id" {
  description = "The GCP project ID where the Compute Engine instance will be created."
  type        = string
}

variable "name" {
  description = "The name of the Compute Engine instance. Must be unique within the project/zone."
  type        = string
}

variable "zone" {
  description = "The GCP zone to create the instance in (e.g. 'us-central1-a')."
  type        = string
}

variable "machine_type" {
  description = "The Compute Engine machine type (e.g. 'e2-medium', 'n2-standard-4')."
  type        = string
  default     = "e2-medium"
}

variable "boot_disk_image" {
  description = "The source image for the boot disk. Can be a family URL (e.g. 'debian-cloud/debian-12') or image self-link."
  type        = string
  default     = "debian-cloud/debian-12"
}

variable "boot_disk_size" {
  description = "The size of the boot disk in GB."
  type        = number
  default     = 50

  validation {
    condition     = var.boot_disk_size >= 10
    error_message = "Boot disk size must be at least 10 GB."
  }
}

variable "boot_disk_type" {
  description = "The type of boot disk. pd-ssd is recommended for production."
  type        = string
  default     = "pd-ssd"

  validation {
    condition     = contains(["pd-standard", "pd-balanced", "pd-ssd", "pd-extreme", "hyperdisk-balanced"], var.boot_disk_type)
    error_message = "Invalid boot_disk_type. Choose from pd-standard, pd-balanced, pd-ssd, pd-extreme, hyperdisk-balanced."
  }
}

variable "boot_disk_auto_delete" {
  description = "Whether to auto-delete the boot disk when the instance is deleted."
  type        = bool
  default     = true
}

variable "network_self_link" {
  description = "The self-link of the VPC network for the instance's primary interface."
  type        = string
}

variable "subnet_self_link" {
  description = "The self-link of the subnetwork for the instance's primary interface."
  type        = string
}

variable "enable_external_ip" {
  description = "Whether to assign an external IP address to the instance. Default is false (private only)."
  type        = bool
  default     = false
}

variable "external_ip_address" {
  description = "A static external IP address to assign. Leave null for an ephemeral IP when enable_external_ip is true."
  type        = string
  default     = null
}

variable "tags" {
  description = "List of network tags to apply to the instance for firewall rule targeting."
  type        = list(string)
  default     = []
}

variable "labels" {
  description = "Key-value labels to apply to the instance and boot disk."
  type        = map(string)
  default     = {}
}

variable "service_account_email" {
  description = "The email of the service account to attach to the instance. Use a dedicated SA with minimal permissions."
  type        = string
}

variable "service_account_scopes" {
  description = "List of OAuth scopes for the service account. Prefer 'cloud-platform' with granular IAM over individual scope grants."
  type        = list(string)
  default     = ["https://www.googleapis.com/auth/cloud-platform"]
}

variable "metadata" {
  description = "Key-value pairs of instance metadata. Merged with security-related metadata set by the module."
  type        = map(string)
  default     = {}
}

variable "block_project_ssh_keys" {
  description = "Whether to block project-wide SSH keys from being used on this instance."
  type        = bool
  default     = true
}

variable "enable_secure_boot" {
  description = "Whether to enable Shielded VM secure boot. Requires a compatible boot image."
  type        = bool
  default     = true
}

variable "enable_vtpm" {
  description = "Whether to enable Shielded VM virtual TPM."
  type        = bool
  default     = true
}

variable "enable_integrity_monitoring" {
  description = "Whether to enable Shielded VM integrity monitoring."
  type        = bool
  default     = true
}

variable "preemptible" {
  description = "Whether to create a preemptible (low-cost, short-lived) instance. Not for production workloads."
  type        = bool
  default     = false
}

variable "spot" {
  description = "Whether to create a Spot VM. Lower cost but can be preempted. Mutually exclusive with preemptible."
  type        = bool
  default     = false
}

variable "allow_stopping_for_update" {
  description = "If true, allows Terraform to stop the instance to apply updates that require it."
  type        = bool
  default     = false
}
