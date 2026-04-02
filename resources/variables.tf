# ---------------------------------------------------------------------------
# Core / global variables
# ---------------------------------------------------------------------------

variable "project_id" {
  description = "Target GCP project ID to deploy resources into"
  type        = string
}

variable "default_region" {
  description = "Default GCP region for all regional resources"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Deployment environment name (e.g. dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "network_self_link" {
  description = "Self-link of the VPC network resources should be placed in"
  type        = string
}

variable "subnet_self_links" {
  description = "Map of subnet self-links keyed by a logical subnet name (e.g. { gke = \"...\", sql = \"...\" })"
  type        = map(string)
  default     = {}
}

variable "labels" {
  description = "Base labels to apply to all resources (merged with environment label)"
  type        = map(string)
  default     = {}
}

# ---------------------------------------------------------------------------
# Feature-flag enable/disable switches
# ---------------------------------------------------------------------------

variable "enable_gke_autopilot" {
  description = "Set to true to create a GKE Autopilot cluster"
  type        = bool
  default     = false
}

variable "enable_gke_self_managed" {
  description = "Set to true to create a GKE Standard (self-managed nodes) cluster"
  type        = bool
  default     = false
}

variable "enable_cloud_sql_postgres" {
  description = "Set to true to create a Cloud SQL for PostgreSQL instance"
  type        = bool
  default     = false
}

variable "enable_cloud_sql_mysql" {
  description = "Set to true to create a Cloud SQL for MySQL instance"
  type        = bool
  default     = false
}

variable "enable_vm_instances" {
  description = "Set to true to create Compute Engine VM instances"
  type        = bool
  default     = false
}

variable "enable_gcs_buckets" {
  description = "Set to true to create GCS buckets"
  type        = bool
  default     = false
}

variable "enable_artifact_registry" {
  description = "Set to true to create an Artifact Registry repository"
  type        = bool
  default     = false
}

variable "enable_cloud_dns" {
  description = "Set to true to create a Cloud DNS managed zone"
  type        = bool
  default     = false
}

variable "enable_bigquery" {
  description = "Set to true to create BigQuery datasets and tables"
  type        = bool
  default     = false
}

# ---------------------------------------------------------------------------
# GKE Autopilot configuration
# ---------------------------------------------------------------------------

variable "gke_autopilot_config" {
  description = "Configuration for the GKE Autopilot cluster"
  type = object({
    name                = string
    subnet_self_link    = string
    pods_range_name     = string
    services_range_name = string
    master_ipv4_cidr_block = string
    master_authorized_networks = list(object({
      cidr_block   = string
      display_name = string
    }))
    release_channel = string
  })
  default = {
    name                       = "autopilot-cluster"
    subnet_self_link           = ""
    pods_range_name            = "pods"
    services_range_name        = "services"
    master_ipv4_cidr_block     = "172.16.0.0/28"
    master_authorized_networks = []
    release_channel            = "REGULAR"
  }
}

# ---------------------------------------------------------------------------
# GKE Standard (self-managed) configuration
# ---------------------------------------------------------------------------

variable "gke_self_managed_config" {
  description = "Configuration for the GKE Standard cluster"
  type = object({
    name                = string
    subnet_self_link    = string
    pods_range_name     = string
    services_range_name = string
    master_ipv4_cidr_block = string
    node_pools = list(object({
      name         = string
      machine_type = string
      min_count    = number
      max_count    = number
      disk_size_gb = number
      disk_type    = string
      image_type   = string
      labels       = map(string)
      tags         = list(string)
    }))
  })
  default = {
    name                       = "standard-cluster"
    subnet_self_link           = ""
    pods_range_name            = "pods"
    services_range_name        = "services"
    master_ipv4_cidr_block     = "172.16.1.0/28"
    node_pools = []
  }
}

# ---------------------------------------------------------------------------
# Cloud SQL – PostgreSQL configuration
# ---------------------------------------------------------------------------

variable "cloud_sql_postgres_config" {
  description = "Configuration for the Cloud SQL PostgreSQL instance"
  type = object({
    instance_name     = string
    database_version  = string
    tier              = string
    disk_size         = number
    availability_type = string
    database_name     = string
    backup_enabled    = bool
    network_self_link = optional(string, "")
  })
  default = {
    instance_name     = "postgres-instance"
    database_version  = "POSTGRES_15"
    tier              = "db-custom-2-8192"
    disk_size         = 20
    availability_type = "ZONAL"
    database_name     = "app"
    backup_enabled    = true
    network_self_link = ""
  }
}

# ---------------------------------------------------------------------------
# Cloud SQL – MySQL configuration
# ---------------------------------------------------------------------------

variable "cloud_sql_mysql_config" {
  description = "Configuration for the Cloud SQL MySQL instance"
  type = object({
    instance_name     = string
    database_version  = string
    tier              = string
    disk_size         = number
    availability_type = string
    database_name     = string
    backup_enabled    = bool
    network_self_link = optional(string, "")
  })
  default = {
    instance_name     = "mysql-instance"
    database_version  = "MYSQL_8_0"
    tier              = "db-custom-2-8192"
    disk_size         = 20
    availability_type = "ZONAL"
    database_name     = "app"
    backup_enabled    = true
    network_self_link = ""
  }
}

# ---------------------------------------------------------------------------
# Compute Engine VM instances
# ---------------------------------------------------------------------------

variable "vm_instances" {
  description = "List of Compute Engine VM instances to create"
  type = list(object({
    name                  = string
    zone                  = string
    machine_type          = string
    boot_disk_image       = string
    boot_disk_size        = number
    subnet_self_link      = string
    service_account_email = string
    tags                  = list(string)
    labels                = map(string)
  }))
  default = []
}

# ---------------------------------------------------------------------------
# GCS Buckets
# ---------------------------------------------------------------------------

variable "gcs_buckets" {
  description = "List of GCS buckets to create"
  type = list(object({
    name               = string
    location           = string
    storage_class      = string
    versioning_enabled = bool
  }))
  default = []
}

# ---------------------------------------------------------------------------
# Artifact Registry
# ---------------------------------------------------------------------------

variable "artifact_registry_config" {
  description = "Configuration for the Artifact Registry repository"
  type = object({
    repository_id = string
    format        = string
    location      = string
    description   = optional(string, "")
  })
  default = {
    repository_id = "app-repo"
    format        = "DOCKER"
    location      = "us-central1"
    description   = ""
  }
}

# ---------------------------------------------------------------------------
# Cloud DNS
# ---------------------------------------------------------------------------

variable "cloud_dns_config" {
  description = "Configuration for the Cloud DNS managed zone"
  type = object({
    zone_name  = string
    dns_name   = string
    visibility = string
    record_sets = list(object({
      name    = string
      type    = string
      ttl     = optional(number, 300)
      rrdatas = list(string)
    }))
  })
  default = {
    zone_name   = "internal-zone"
    dns_name    = "internal.example.com."
    visibility  = "private"
    record_sets = []
  }
}

# ---------------------------------------------------------------------------
# BigQuery
# ---------------------------------------------------------------------------

variable "bigquery_config" {
  description = "Configuration for BigQuery datasets and tables"
  type = object({
    dataset_id = string
    location   = string
    tables = list(object({
      table_id    = string
      description = optional(string, "")
      schema      = optional(string, "[]")
    }))
  })
  default = {
    dataset_id = "app_dataset"
    location   = "US"
    tables     = []
  }
}
