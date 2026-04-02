variable "project_id" {
  description = "The GCP project ID where the Artifact Registry repository will be created."
  type        = string
}

variable "location" {
  description = "The GCP location for the repository (e.g. 'us-central1', 'us', 'europe')."
  type        = string
}

variable "repository_id" {
  description = "The repository ID. Must be unique within the project and location. Only lowercase letters, numbers, and hyphens are allowed."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,61}[a-z0-9]$", var.repository_id))
    error_message = "repository_id must be lowercase, start with a letter, and be 2-63 characters."
  }
}

variable "format" {
  description = "The format of the repository. Examples: DOCKER, MAVEN, NPM, APT, YUM, PYTHON, GO."
  type        = string
  default     = "DOCKER"

  validation {
    condition     = contains(["DOCKER", "MAVEN", "NPM", "APT", "YUM", "PYTHON", "GO", "HELM", "GENERIC"], var.format)
    error_message = "format must be one of: DOCKER, MAVEN, NPM, APT, YUM, PYTHON, GO, HELM, GENERIC."
  }
}

variable "description" {
  description = "A human-readable description for the repository."
  type        = string
  default     = ""
}

variable "labels" {
  description = "Key-value labels to apply to the repository."
  type        = map(string)
  default     = {}
}

variable "mode" {
  description = "The mode of the repository. STANDARD_REPOSITORY, VIRTUAL_REPOSITORY, or REMOTE_REPOSITORY."
  type        = string
  default     = "STANDARD_REPOSITORY"

  validation {
    condition     = contains(["STANDARD_REPOSITORY", "VIRTUAL_REPOSITORY", "REMOTE_REPOSITORY"], var.mode)
    error_message = "mode must be STANDARD_REPOSITORY, VIRTUAL_REPOSITORY, or REMOTE_REPOSITORY."
  }
}

variable "docker_immutable_tags" {
  description = "For DOCKER repositories, whether to make tags immutable (prevents overwriting existing tags)."
  type        = bool
  default     = false
}

variable "cleanup_policies" {
  description = <<-EOT
    Map of cleanup policy ID to policy config. Each entry has:
    - action: 'DELETE' or 'KEEP'
    - condition: (optional) object with tag_state, tag_prefixes, older_than, newer_than, package_name_prefixes, version_name_prefixes
    - most_recent_versions: (optional) object with keep_count and package_name_prefixes
  EOT
  type = map(object({
    action = string
    condition = optional(object({
      tag_state             = optional(string)
      tag_prefixes          = optional(list(string))
      older_than            = optional(string)
      newer_than            = optional(string)
      package_name_prefixes = optional(list(string))
      version_name_prefixes = optional(list(string))
    }))
    most_recent_versions = optional(object({
      keep_count            = optional(number)
      package_name_prefixes = optional(list(string))
    }))
  }))
  default = {}
}

variable "upstream_policies" {
  description = "List of upstream policies for VIRTUAL_REPOSITORY mode."
  type = list(object({
    id         = string
    repository = string
    priority   = number
  }))
  default = []
}

variable "remote_repository_upstream_url" {
  description = "The upstream URL for REMOTE_REPOSITORY mode (proxy/cache)."
  type        = string
  default     = null
}

variable "readers" {
  description = "List of IAM members (e.g. 'serviceAccount:sa@project.iam.gserviceaccount.com') to grant artifactregistry.reader role."
  type        = list(string)
  default     = []
}

variable "writers" {
  description = "List of IAM members to grant artifactregistry.writer role."
  type        = list(string)
  default     = []
}
