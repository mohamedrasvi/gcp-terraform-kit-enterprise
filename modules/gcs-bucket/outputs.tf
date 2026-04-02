output "bucket_name" {
  description = "The name of the created GCS bucket."
  value       = google_storage_bucket.bucket.name
}

output "bucket_url" {
  description = "The base URL of the bucket, in the form gs://<bucket-name>."
  value       = google_storage_bucket.bucket.url
}

output "bucket_self_link" {
  description = "The URI of the bucket."
  value       = google_storage_bucket.bucket.self_link
}

output "bucket_id" {
  description = "The ID of the bucket resource."
  value       = google_storage_bucket.bucket.id
}

output "project" {
  description = "The project the bucket belongs to."
  value       = google_storage_bucket.bucket.project
}
