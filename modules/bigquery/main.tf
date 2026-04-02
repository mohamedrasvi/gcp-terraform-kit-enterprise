terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0.0"
    }
  }
}

resource "google_bigquery_dataset" "dataset" {
  project                         = var.project_id
  dataset_id                      = var.dataset_id
  friendly_name                   = var.friendly_name != null ? var.friendly_name : var.dataset_id
  description                     = var.description
  location                        = var.location
  default_table_expiration_ms     = var.default_table_expiration_ms
  default_partition_expiration_ms = var.default_partition_expiration_ms
  labels                          = var.labels
  delete_contents_on_destroy      = var.delete_contents_on_destroy

  dynamic "default_encryption_configuration" {
    for_each = var.encryption_key != null ? [1] : []
    content {
      kms_key_name = var.encryption_key
    }
  }

  dynamic "access" {
    for_each = var.access
    content {
      role          = lookup(access.value, "role", null)
      user_by_email = lookup(access.value, "user_by_email", null)
      group_by_email = lookup(access.value, "group_by_email", null)
      domain        = lookup(access.value, "domain", null)
      special_group = lookup(access.value, "special_group", null)
    }
  }
}

resource "google_bigquery_table" "tables" {
  for_each = { for t in var.tables : t.table_id => t }

  project             = var.project_id
  dataset_id          = google_bigquery_dataset.dataset.dataset_id
  table_id            = each.value.table_id
  description         = lookup(each.value, "description", "")
  deletion_protection = lookup(each.value, "deletion_protection", true)
  labels              = merge(var.labels, lookup(each.value, "labels", {}))

  # Schema from a JSON string or file reference (passed as string content)
  schema = lookup(each.value, "schema", null)

  dynamic "time_partitioning" {
    for_each = lookup(each.value, "time_partitioning", null) != null ? [each.value.time_partitioning] : []
    content {
      type                     = time_partitioning.value.type
      field                    = lookup(time_partitioning.value, "field", null)
      expiration_ms            = lookup(time_partitioning.value, "expiration_ms", null)
      require_partition_filter = lookup(time_partitioning.value, "require_partition_filter", false)
    }
  }

  dynamic "range_partitioning" {
    for_each = lookup(each.value, "range_partitioning", null) != null ? [each.value.range_partitioning] : []
    content {
      field = range_partitioning.value.field
      range {
        start    = range_partitioning.value.range.start
        end      = range_partitioning.value.range.end
        interval = range_partitioning.value.range.interval
      }
    }
  }

  clustering = length(lookup(each.value, "clustering_fields", [])) > 0 ? each.value.clustering_fields : null

  dynamic "encryption_configuration" {
    for_each = var.encryption_key != null ? [1] : []
    content {
      kms_key_name = var.encryption_key
    }
  }
}
