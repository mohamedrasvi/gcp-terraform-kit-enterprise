terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4"
    }
  }
}

# Reserve a global internal IP range for the private service connection
resource "google_compute_global_address" "private_ip_range" {
  project       = var.project_id
  name          = "${var.instance_name}-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 20
  network       = var.network_self_link
  description   = "Private IP range for Cloud SQL instance ${var.instance_name}"
}

# Establish the private service connection (VPC peering with Google services)
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = var.network_self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_range.name]
}

# Suffix for instance name to ensure uniqueness on re-create
resource "random_id" "instance_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "postgres" {
  project             = var.project_id
  name                = "${var.instance_name}-${random_id.instance_suffix.hex}"
  region              = var.region
  database_version    = var.database_version
  deletion_protection = var.deletion_protection

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier                        = var.tier
    availability_type           = var.availability_type
    disk_size                   = var.disk_size
    disk_type                   = var.disk_type
    disk_autoresize             = var.disk_autoresize
    disk_autoresize_limit       = var.disk_autoresize_limit
    deletion_protection_enabled = var.deletion_protection

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = var.network_self_link
      enable_private_path_for_google_cloud_services = true
      ssl_mode                                      = "ENCRYPTED_ONLY"
    }

    backup_configuration {
      enabled                        = var.backup_enabled
      start_time                     = var.backup_start_time
      point_in_time_recovery_enabled = var.point_in_time_recovery_enabled
      transaction_log_retention_days = var.transaction_log_retention_days
      backup_retention_settings {
        retained_backups = var.retained_backups
        retention_unit   = "COUNT"
      }
    }

    maintenance_window {
      day          = var.maintenance_window_day
      hour         = var.maintenance_window_hour
      update_track = var.maintenance_window_update_track
    }

    insights_config {
      query_insights_enabled  = var.query_insights_enabled
      query_string_length     = var.query_string_length
      record_application_tags = var.record_application_tags
      record_client_address   = var.record_client_address
    }

    dynamic "database_flags" {
      for_each = var.database_flags
      content {
        name  = database_flags.value.name
        value = database_flags.value.value
      }
    }

    user_labels = var.labels
  }
}

resource "google_sql_database" "database" {
  project   = var.project_id
  instance  = google_sql_database_instance.postgres.name
  name      = var.database_name
  charset   = "UTF8"
  collation = "en_US.UTF8"
}
