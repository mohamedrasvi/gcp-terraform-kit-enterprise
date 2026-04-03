variable "project_id" {
  description = "The GCP project ID where the Cloud SQL instance will be created."
  type        = string
}

variable "private_connection_id" {
  description = "The ID of the shared private service networking connection (from the sql-private-connection module). This must be created before any Cloud SQL instance in the same VPC."
  type        = string
}

variable "region" {
  description = "The GCP region for the Cloud SQL instance."
  type        = string
}

variable "instance_name" {
  description = "The base name for the Cloud SQL instance. A random suffix will be appended to ensure uniqueness on re-creation."
  type        = string
}

variable "database_version" {
  description = "The PostgreSQL version to use. Must be a valid PostgreSQL version string."
  type        = string
  default     = "POSTGRES_15"

  validation {
    condition     = can(regex("^POSTGRES_[0-9]+$", var.database_version))
    error_message = "database_version must be in the format 'POSTGRES_<major_version>' (e.g. POSTGRES_15)."
  }
}

variable "tier" {
  description = "The machine type/tier for the Cloud SQL instance (e.g. 'db-custom-2-7680', 'db-n1-standard-4')."
  type        = string
  default     = "db-custom-2-7680"
}

variable "disk_size" {
  description = "The disk size in GB for the Cloud SQL instance."
  type        = number
  default     = 100

  validation {
    condition     = var.disk_size >= 10
    error_message = "Disk size must be at least 10 GB."
  }
}

variable "disk_type" {
  description = "The type of disk to use for the Cloud SQL instance. PD_SSD is recommended for production."
  type        = string
  default     = "PD_SSD"

  validation {
    condition     = contains(["PD_SSD", "PD_HDD"], var.disk_type)
    error_message = "disk_type must be either 'PD_SSD' or 'PD_HDD'."
  }
}

variable "disk_autoresize" {
  description = "Whether to automatically increase disk size when storage is nearly full."
  type        = bool
  default     = true
}

variable "disk_autoresize_limit" {
  description = "Maximum disk size in GB for automatic resize. Set to 0 for unlimited."
  type        = number
  default     = 0
}

variable "availability_type" {
  description = "The availability type for the instance. REGIONAL enables HA with automatic failover. ZONAL is single-zone."
  type        = string
  default     = "REGIONAL"

  validation {
    condition     = contains(["REGIONAL", "ZONAL"], var.availability_type)
    error_message = "availability_type must be either 'REGIONAL' or 'ZONAL'."
  }
}

variable "network_self_link" {
  description = "The self-link of the VPC network for private IP connectivity."
  type        = string
}

variable "database_name" {
  description = "The name of the default database to create on the instance."
  type        = string
}

variable "backup_enabled" {
  description = "Whether to enable automated backups."
  type        = bool
  default     = true
}

variable "backup_start_time" {
  description = "HH:MM format time when the daily backup window starts."
  type        = string
  default     = "02:00"
}

variable "point_in_time_recovery_enabled" {
  description = "Whether to enable point-in-time recovery. Requires backup_enabled = true."
  type        = bool
  default     = true
}

variable "transaction_log_retention_days" {
  description = "The number of days of transaction logs to retain for point-in-time recovery."
  type        = number
  default     = 7
}

variable "retained_backups" {
  description = "The number of automated backups to retain."
  type        = number
  default     = 14
}

variable "maintenance_window_day" {
  description = "Day of the week for the maintenance window (1=Monday ... 7=Sunday)."
  type        = number
  default     = 7

  validation {
    condition     = var.maintenance_window_day >= 1 && var.maintenance_window_day <= 7
    error_message = "maintenance_window_day must be between 1 (Monday) and 7 (Sunday)."
  }
}

variable "maintenance_window_hour" {
  description = "Hour of the day (UTC) for the maintenance window (0-23)."
  type        = number
  default     = 4

  validation {
    condition     = var.maintenance_window_hour >= 0 && var.maintenance_window_hour <= 23
    error_message = "maintenance_window_hour must be between 0 and 23."
  }
}

variable "maintenance_window_update_track" {
  description = "The update track for the maintenance window. 'stable' receives updates after 'canary'."
  type        = string
  default     = "stable"

  validation {
    condition     = contains(["stable", "canary", "week5"], var.maintenance_window_update_track)
    error_message = "maintenance_window_update_track must be 'stable', 'canary', or 'week5'."
  }
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection on the Cloud SQL instance. Strongly recommended for production."
  type        = bool
  default     = true
}

variable "query_insights_enabled" {
  description = "Whether to enable Query Insights for performance analysis."
  type        = bool
  default     = true
}

variable "query_string_length" {
  description = "Maximum length of query strings logged by Query Insights (bytes)."
  type        = number
  default     = 1024
}

variable "record_application_tags" {
  description = "Whether to record application tags in Query Insights."
  type        = bool
  default     = false
}

variable "record_client_address" {
  description = "Whether to record client IP addresses in Query Insights."
  type        = bool
  default     = false
}

variable "database_flags" {
  description = "List of database flags to set on the instance. Each flag has a 'name' and 'value'."
  type = list(object({
    name  = string
    value = string
  }))
  default = [
    { name = "log_checkpoints", value = "on" },
    { name = "log_connections", value = "on" },
    { name = "log_disconnections", value = "on" },
    { name = "log_lock_waits", value = "on" },
    { name = "log_min_duration_statement", value = "1000" },
    { name = "cloudsql.enable_pgaudit", value = "on" },
  ]
}

variable "labels" {
  description = "Labels to apply to the Cloud SQL instance for organization and cost attribution."
  type        = map(string)
  default     = {}
}
