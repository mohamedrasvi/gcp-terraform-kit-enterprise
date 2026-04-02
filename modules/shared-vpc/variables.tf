variable "host_project_id" {
  description = "The project ID of the Shared VPC host project. This project must have the Compute Engine API enabled."
  type        = string
}

variable "service_project_ids" {
  description = "List of GCP project IDs to attach as Shared VPC service projects. These projects will be able to use network resources from the host project."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.service_project_ids) > 0
    error_message = "At least one service project ID must be provided."
  }
}

variable "network_name" {
  description = "The name of the Shared VPC network in the host project. Used for documentation/reference; the VPC itself is created via the vpc module."
  type        = string
  default     = null
}
