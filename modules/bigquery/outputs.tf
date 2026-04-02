output "dataset_id" {
  description = "The ID of the created BigQuery dataset."
  value       = google_bigquery_dataset.dataset.dataset_id
}

output "dataset_self_link" {
  description = "The URI of the created BigQuery dataset."
  value       = google_bigquery_dataset.dataset.self_link
}

output "table_ids" {
  description = "Map of table ID to the fully qualified table resource name."
  value = {
    for tid, table in google_bigquery_table.tables : tid => table.id
  }
}

output "table_self_links" {
  description = "Map of table ID to the table self-link."
  value = {
    for tid, table in google_bigquery_table.tables : tid => table.self_link
  }
}

output "creation_time" {
  description = "The time when the dataset was created, in milliseconds since the epoch."
  value       = google_bigquery_dataset.dataset.creation_time
}
