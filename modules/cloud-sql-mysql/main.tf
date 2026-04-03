terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
      # Secret Manager resources (google_secret_manager_secret, google_secret_manager_secret_version)
      # are included in the hashicorp/google provider — no separate provider needed.
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4"
    }
  }
}

# Suffix for instance name to ensure uniqueness on re-create (Cloud SQL instance
# names are reserved for up to one week after deletion).
resource "random_id" "instance_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "mysql" {
  project             = var.project_id
  name                = "${var.instance_name}-${random_id.instance_suffix.hex}"
  region              = var.region
  database_version    = var.database_version
  deletion_protection = var.deletion_protection

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [var.private_connection_id]

  settings {
    tier                        = var.tier
    availability_type           = var.availability_type
    disk_size                   = var.disk_size
    disk_type                   = var.disk_type
    disk_autoresize             = var.disk_autoresize
    disk_autoresize_limit       = var.disk_autoresize_limit
    deletion_protection_enabled = var.deletion_protection

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_self_link
      ssl_mode        = "ENCRYPTED_ONLY"
    }

    backup_configuration {
      enabled                        = var.backup_enabled
      start_time                     = var.backup_start_time
      point_in_time_recovery_enabled = var.point_in_time_recovery_enabled
      transaction_log_retention_days = var.transaction_log_retention_days
      binary_log_enabled             = var.binary_log_enabled
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
  project  = var.project_id
  instance = google_sql_database_instance.mysql.name
  name     = var.database_name
  charset  = "utf8mb4"
  collation = "utf8mb4_unicode_ci"
}

# ---------------------------------------------------------------------------
# Optional database user + Secret Manager password storage (#4)
# ---------------------------------------------------------------------------

resource "random_password" "db_password" {
  count            = var.create_db_user ? 1 : 0
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}|;:,.<>?"
}

resource "google_sql_user" "app_user" {
  count    = var.create_db_user ? 1 : 0
  project  = var.project_id
  instance = google_sql_database_instance.mysql.name
  name     = var.db_username
  password = random_password.db_password[0].result

  deletion_policy = "ABANDON"
}

resource "google_secret_manager_secret" "db_password" {
  count     = var.create_db_user ? 1 : 0
  project   = var.project_id
  secret_id = "${var.instance_name}-db-password"

  replication {
    auto {}
  }

  labels = var.labels
}

resource "google_secret_manager_secret_version" "db_password" {
  count       = var.create_db_user ? 1 : 0
  secret      = google_secret_manager_secret.db_password[0].id
  secret_data = random_password.db_password[0].result

  lifecycle {
    ignore_changes = [secret_data]
  }
}
