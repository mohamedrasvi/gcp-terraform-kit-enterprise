variable "project_id" {
  description = "The GCP project ID where monitoring resources will be created."
  type        = string
}

variable "notification_channels" {
  description = <<-EOT
    List of notification channel configuration objects. Each object has:
    - name         (required) string: Unique key for the channel within this module.
    - display_name (required) string: Human-readable name for the channel.
    - type         (required) string: Channel type (email, slack, pagerduty, webhook_basicauth, pubsub, etc.).
    - labels       (required) map(string): Channel-specific configuration labels (e.g. {email_address = "ops@example.com"}).
    - enabled      (optional) bool: Whether the channel is enabled (default: true).
    - auth_token   (optional) string: Authentication token for channels that require it (e.g. Slack).
  EOT
  type = list(object({
    name         = string
    display_name = string
    type         = string
    labels       = map(string)
    enabled      = optional(bool, true)
    auth_token   = optional(string)
  }))
  default = []
}

variable "enable_default_policies" {
  description = "Whether to create the built-in default alert policies (CPU, memory, disk, uptime)."
  type        = bool
  default     = true
}

variable "cpu_utilization_threshold" {
  description = "CPU utilization fraction (0.0-1.0) above which the high CPU alert fires."
  type        = number
  default     = 0.8

  validation {
    condition     = var.cpu_utilization_threshold > 0 && var.cpu_utilization_threshold <= 1
    error_message = "cpu_utilization_threshold must be between 0 and 1."
  }
}

variable "memory_utilization_threshold" {
  description = "Memory utilization fraction (0.0-1.0) above which the high memory alert fires. The Ops Agent metric agent.googleapis.com/memory/percent_used returns 0-100, so this value is multiplied by 100 before comparison."
  type        = number
  default     = 0.85

  validation {
    condition     = var.memory_utilization_threshold > 0 && var.memory_utilization_threshold <= 1
    error_message = "memory_utilization_threshold must be between 0 and 1 (e.g. 0.85 for 85%)."
  }
}

variable "disk_usage_threshold" {
  description = "Disk usage fraction (0.0-1.0) above which the disk usage alert fires. The Ops Agent metric agent.googleapis.com/disk/percent_used returns 0-100, so this value is multiplied by 100 before comparison."
  type        = number
  default     = 0.80

  validation {
    condition     = var.disk_usage_threshold > 0 && var.disk_usage_threshold <= 1
    error_message = "disk_usage_threshold must be between 0 and 1 (e.g. 0.80 for 80%)."
  }
}

variable "uptime_check_ids" {
  description = "List of uptime check IDs to monitor for failures. Required for the uptime check alert policy."
  type        = list(string)
  default     = []
}

variable "alert_policies" {
  description = <<-EOT
    List of custom alert policy objects. Each object has:
    - display_name  (required) string: Alert policy display name.
    - combiner      (optional) string: Condition combiner: OR or AND (default: OR).
    - enabled       (optional) bool: Whether the alert is active (default: true).
    - conditions    (required) list(object): List of conditions with display_name and condition_threshold.
    - documentation (optional) object: Documentation with content and mime_type.
    - additional_notification_channels (optional) list(string): Extra channel IDs beyond module-level channels.

    Each condition_threshold has: filter, duration, comparison, threshold_value,
    alignment_period, per_series_aligner, cross_series_reducer, group_by_fields,
    trigger_count, trigger_percent.
  EOT
  type = list(object({
    display_name = string
    combiner     = optional(string, "OR")
    enabled      = optional(bool, true)
    additional_notification_channels = optional(list(string), [])
    conditions = list(object({
      display_name = string
      condition_threshold = optional(object({
        filter               = string
        duration             = string
        comparison           = string
        threshold_value      = number
        alignment_period     = optional(string, "60s")
        per_series_aligner   = optional(string, "ALIGN_MEAN")
        cross_series_reducer = optional(string)
        group_by_fields      = optional(list(string), [])
        trigger_count        = optional(number, 1)
        trigger_percent      = optional(number)
      }))
    }))
    documentation = optional(object({
      content   = string
      mime_type = optional(string, "text/markdown")
    }))
  }))
  default = []
}

variable "monitored_projects" {
  description = "List of project IDs to attach as monitored projects in this project's metrics scope (for folder-wide monitoring)."
  type        = list(string)
  default     = []
}

variable "create_dashboard" {
  description = "Whether to create a monitoring dashboard."
  type        = bool
  default     = true
}

variable "dashboard_display_name" {
  description = "Display name for the auto-generated monitoring dashboard."
  type        = string
  default     = "Infrastructure Overview"
}

variable "dashboard_json" {
  description = "Custom JSON string for the dashboard layout. If provided, overrides the auto-generated dashboard."
  type        = string
  default     = null
}
