terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}

# ---------------------------------------------------------------------------
# Log Bucket for centralized log storage
# ---------------------------------------------------------------------------

resource "google_logging_project_bucket_config" "log_bucket" {
  count = var.log_bucket_name != null ? 1 : 0

  project          = var.project_id
  location         = var.log_bucket_location
  bucket_id        = var.log_bucket_name
  retention_days   = var.log_bucket_retention_days
  locked           = var.log_bucket_locked
  description      = "Centralized log bucket for project ${var.project_id}"

  # Enable analytics for logs that are analyzed in Log Analytics
  enable_analytics = var.log_bucket_enable_analytics
}

# ---------------------------------------------------------------------------
# Log Sinks
# ---------------------------------------------------------------------------

resource "google_logging_project_sink" "sinks" {
  for_each = { for s in var.log_sinks : s.name => s }

  project          = var.project_id
  name             = each.value.name
  destination      = each.value.destination
  filter           = lookup(each.value, "filter", "")
  description      = lookup(each.value, "description", "")
  disabled         = lookup(each.value, "disabled", false)

  # For org/folder-wide sinks that aggregate from child resources
  # individual project sinks don't support include_children
  unique_writer_identity = true

  dynamic "bigquery_options" {
    for_each = can(regex("^bigquery\\.googleapis\\.com", each.value.destination)) ? [1] : []
    content {
      use_partitioned_tables = lookup(each.value, "use_partitioned_tables", true)
    }
  }

  dynamic "exclusions" {
    for_each = lookup(each.value, "exclusions", [])
    content {
      name        = exclusions.value.name
      description = lookup(exclusions.value, "description", "")
      filter      = exclusions.value.filter
      disabled    = lookup(exclusions.value, "disabled", false)
    }
  }
}

# ---------------------------------------------------------------------------
# BigQuery dataset for log export (optional)
# ---------------------------------------------------------------------------

resource "google_bigquery_dataset" "log_export" {
  count = var.export_to_bigquery && var.bigquery_dataset_id != null ? 1 : 0

  project     = var.project_id
  dataset_id  = var.bigquery_dataset_id
  location    = var.bigquery_dataset_location
  description = "BigQuery dataset for exported logs from project ${var.project_id}"

  delete_contents_on_destroy = false

  default_partition_expiration_ms = var.bigquery_partition_expiration_days != null ? (
    var.bigquery_partition_expiration_days * 24 * 60 * 60 * 1000
  ) : null
}

# Grant the sink's writer identity access to the BigQuery dataset
resource "google_bigquery_dataset_iam_member" "log_export_bq" {
  for_each = {
    for name, sink in google_logging_project_sink.sinks :
    name => sink
    if can(regex("^bigquery\\.googleapis\\.com", sink.destination))
  }

  project    = var.project_id
  dataset_id = var.bigquery_dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = each.value.writer_identity
}

# ---------------------------------------------------------------------------
# Log-based metrics
# ---------------------------------------------------------------------------

resource "google_logging_metric" "metrics" {
  for_each = { for m in var.log_based_metrics : m.name => m }

  project     = var.project_id
  name        = each.value.name
  description = lookup(each.value, "description", "")
  filter      = each.value.filter

  metric_descriptor {
    metric_kind  = lookup(each.value, "metric_kind", "DELTA")
    value_type   = lookup(each.value, "value_type", "INT64")
    unit         = lookup(each.value, "unit", "1")
    display_name = lookup(each.value, "display_name", each.value.name)
  }
}
