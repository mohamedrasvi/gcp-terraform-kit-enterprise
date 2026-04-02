variable "project_id" {
  description = "The GCP project ID where the BigQuery dataset will be created."
  type        = string
}

variable "dataset_id" {
  description = "The BigQuery dataset ID. Must be unique within the project. Only letters, numbers, and underscores allowed."
  type        = string

  validation {
    condition     = length(var.dataset_id) == 0 || can(regex("^[a-zA-Z0-9_]{1,1024}$", var.dataset_id))
    error_message = "dataset_id must be 1-1024 characters and contain only letters, numbers, and underscores."
  }
}

variable "friendly_name" {
  description = "A human-readable display name for the dataset. Defaults to dataset_id if not provided."
  type        = string
  default     = null
}

variable "description" {
  description = "A description for the BigQuery dataset."
  type        = string
  default     = ""
}

variable "location" {
  description = "The geographic location for the dataset (e.g. 'US', 'EU', 'us-central1')."
  type        = string
  default     = "US"
}

variable "default_table_expiration_ms" {
  description = "Default lifetime in milliseconds for tables in the dataset. Tables will be deleted after this duration. Set to null for no expiration."
  type        = number
  default     = null
}

variable "default_partition_expiration_ms" {
  description = "Default lifetime in milliseconds for partitions in partitioned tables. Set to null for no expiration."
  type        = number
  default     = null
}

variable "delete_contents_on_destroy" {
  description = "If true, Terraform will delete all tables in the dataset before destroying the dataset resource."
  type        = bool
  default     = false
}

variable "labels" {
  description = "Key-value labels to apply to the dataset and all tables."
  type        = map(string)
  default     = {}
}

variable "encryption_key" {
  description = "Cloud KMS key name for customer-managed encryption of dataset and tables. Leave null for Google-managed keys."
  type        = string
  default     = null
}

variable "access" {
  description = <<-EOT
    List of access control entries for the dataset. Each entry is an object with one of:
    - role + user_by_email
    - role + group_by_email
    - role + service_account
    - role + domain
    - role + special_group (projectOwners, projectReaders, projectWriters, allAuthenticatedUsers)
    Valid roles: READER, WRITER, OWNER.
  EOT
  type = list(object({
    role            = optional(string)
    user_by_email   = optional(string)
    group_by_email  = optional(string)
    service_account = optional(string)
    domain          = optional(string)
    special_group   = optional(string)
  }))
  default = []
}

variable "tables" {
  description = <<-EOT
    List of BigQuery table configuration objects. Each object supports:
    - table_id              (required) string: The table ID.
    - schema                (optional) string: JSON schema string for the table.
    - description           (optional) string: Table description.
    - deletion_protection   (optional) bool: Prevent table deletion (default: true).
    - labels                (optional) map(string): Additional labels for this table.
    - clustering_fields     (optional) list(string): Fields to cluster by.
    - time_partitioning     (optional) object: Partitioning config with type, field, expiration_ms, require_partition_filter.
    - range_partitioning    (optional) object: Range partitioning config with field and range.
  EOT
  type = list(object({
    table_id            = string
    schema              = optional(string)
    description         = optional(string, "")
    deletion_protection = optional(bool, true)
    labels              = optional(map(string), {})
    clustering_fields   = optional(list(string), [])
    time_partitioning = optional(object({
      type                     = string
      field                    = optional(string)
      expiration_ms            = optional(number)
      require_partition_filter = optional(bool, false)
    }))
    range_partitioning = optional(object({
      field = string
      range = object({
        start    = number
        end      = number
        interval = number
      })
    }))
  }))
  default = []
}
