variable "project_id" {
  description = "The GCP project ID where logging resources will be created."
  type        = string
}

variable "log_sinks" {
  description = <<-EOT
    List of log sink configuration objects. Each object has:
    - name        (required) string: The name of the sink resource.
    - destination (required) string: The destination URI. Examples:
        "storage.googleapis.com/my-bucket"
        "bigquery.googleapis.com/projects/my-project/datasets/my_dataset"
        "pubsub.googleapis.com/projects/my-project/topics/my-topic"
        "logging.googleapis.com/projects/my-project/locations/global/buckets/my-bucket"
    - filter      (optional) string: Log filter expression. Empty string exports all logs.
    - description (optional) string: Human-readable description.
    - disabled    (optional) bool: Whether the sink is disabled.
    - use_partitioned_tables (optional) bool: For BigQuery sinks, use date-partitioned tables (default: true).
    - exclusions  (optional) list: Exclusion rules with name, filter, description, disabled.
  EOT
  type = list(object({
    name                   = string
    destination            = string
    filter                 = optional(string, "")
    description            = optional(string, "")
    disabled               = optional(bool, false)
    use_partitioned_tables = optional(bool, true)
    exclusions = optional(list(object({
      name        = string
      filter      = string
      description = optional(string, "")
      disabled    = optional(bool, false)
    })), [])
  }))
  default = []
}

variable "log_bucket_name" {
  description = "The ID for the log bucket to create in Cloud Logging. Set to null to skip log bucket creation."
  type        = string
  default     = null
}

variable "log_bucket_location" {
  description = "The location for the Cloud Logging log bucket (e.g. 'global', 'us-central1')."
  type        = string
  default     = "global"
}

variable "log_bucket_retention_days" {
  description = "The number of days to retain logs in the Cloud Logging bucket. Minimum is 1 day."
  type        = number
  default     = 365

  validation {
    condition     = var.log_bucket_retention_days >= 1
    error_message = "log_bucket_retention_days must be at least 1."
  }
}

variable "log_bucket_locked" {
  description = "Whether to lock the log bucket (prevents retention period reduction or bucket deletion). Use for compliance."
  type        = bool
  default     = false
}

variable "log_bucket_enable_analytics" {
  description = "Whether to enable Log Analytics on the log bucket for BigQuery-based log analysis."
  type        = bool
  default     = false
}

variable "export_to_bigquery" {
  description = "Whether to create a BigQuery dataset for log exports. Requires bigquery_dataset_id to be set."
  type        = bool
  default     = false
}

variable "bigquery_dataset_id" {
  description = "The BigQuery dataset ID for log exports. Required when export_to_bigquery is true."
  type        = string
  default     = null
}

variable "bigquery_dataset_location" {
  description = "The location for the BigQuery dataset used for log exports."
  type        = string
  default     = "US"
}

variable "bigquery_partition_expiration_days" {
  description = "Number of days after which BigQuery partitions expire. Set to null for no expiration."
  type        = number
  default     = 365
}

variable "log_based_metrics" {
  description = <<-EOT
    List of log-based metric configuration objects. Each object has:
    - name         (required) string: Metric name (unique within the project).
    - filter       (required) string: Log filter expression to match log entries.
    - description  (optional) string: Human-readable description.
    - display_name (optional) string: Metric display name.
    - metric_kind  (optional) string: DELTA, GAUGE, or CUMULATIVE (default: DELTA).
    - value_type   (optional) string: INT64, DOUBLE, STRING, DISTRIBUTION, BOOL (default: INT64).
    - unit         (optional) string: Measurement unit (default: '1').
  EOT
  type = list(object({
    name         = string
    filter       = string
    description  = optional(string, "")
    display_name = optional(string, "")
    metric_kind  = optional(string, "DELTA")
    value_type   = optional(string, "INT64")
    unit         = optional(string, "1")
  }))
  default = []
}
