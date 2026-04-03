variable "project_id" {
  description = "The GCP project ID where the Cloud SQL MySQL instance will be created."
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
  description = "The MySQL version to use."
  type        = string
  default     = "MYSQL_8_0"

  validation {
    condition     = can(regex("^MYSQL_[0-9_]+$", var.database_version))
    error_message = "database_version must be in the format 'MYSQL_<version>' (e.g. MYSQL_8_0)."
  }
}

variable "tier" {
  description = "The machine type/tier for the Cloud SQL instance (e.g. 'db-custom-4-15360', 'db-n1-standard-4')."
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
  description = "The type of disk to use for the Cloud SQL instance."
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
  description = "HH:MM format time (UTC) when the daily backup window starts."
  type        = string
  default     = "02:00"
}

variable "point_in_time_recovery_enabled" {
  description = "Whether to enable point-in-time recovery. Requires binary_log_enabled = true."
  type        = bool
  default     = true
}

variable "binary_log_enabled" {
  description = "Whether to enable binary logging. Required for point-in-time recovery. Not compatible with REGIONAL availability_type (which has its own replication)."
  type        = bool
  default     = false
}

variable "transaction_log_retention_days" {
  description = "The number of days to retain transaction logs for PITR."
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
  description = "Whether to enable deletion protection on the Cloud SQL instance."
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
  description = "List of database flags to set on the MySQL instance."
  type = list(object({
    name  = string
    value = string
  }))
  default = [
    { name = "slow_query_log", value = "on" },
    { name = "long_query_time", value = "1" },
    { name = "log_output", value = "FILE" },
    { name = "general_log", value = "off" },
  ]
}

variable "labels" {
  description = "Labels to apply to the Cloud SQL instance."
  type        = map(string)
  default     = {}
}
