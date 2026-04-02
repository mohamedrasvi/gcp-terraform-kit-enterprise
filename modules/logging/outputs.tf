output "sink_ids" {
  description = "Map of log sink name to resource ID."
  value = {
    for name, sink in google_logging_project_sink.sinks : name => sink.id
  }
}

output "sink_writer_identities" {
  description = "Map of log sink name to its writer identity (service account). Grant this identity write access to the destination."
  value = {
    for name, sink in google_logging_project_sink.sinks : name => sink.writer_identity
  }
}

output "log_bucket_id" {
  description = "The resource ID of the Cloud Logging bucket, if created."
  value       = length(google_logging_project_bucket_config.log_bucket) > 0 ? google_logging_project_bucket_config.log_bucket[0].id : null
}

output "log_bucket_name" {
  description = "The bucket ID of the Cloud Logging log bucket, if created."
  value       = length(google_logging_project_bucket_config.log_bucket) > 0 ? google_logging_project_bucket_config.log_bucket[0].bucket_id : null
}

output "bigquery_dataset_id" {
  description = "The BigQuery dataset ID for log exports, if created."
  value       = length(google_bigquery_dataset.log_export) > 0 ? google_bigquery_dataset.log_export[0].dataset_id : null
}

output "log_based_metric_names" {
  description = "Map of log-based metric name to the resource name."
  value = {
    for name, m in google_logging_metric.metrics : name => m.name
  }
}
