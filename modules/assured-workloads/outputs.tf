output "workload_id" {
  description = "The full resource name of the Assured Workloads workload."
  value       = google_assured_workloads_workload.workload.id
}

output "workload_name" {
  description = "The unique name of the workload (server-generated)."
  value       = google_assured_workloads_workload.workload.name
}

output "compliance_regime" {
  description = "The compliance regime of the workload (e.g. HIPAA)."
  value       = google_assured_workloads_workload.workload.compliance_regime
}

output "resources" {
  description = "List of resources provisioned by the Assured Workload (projects, folders, KMS keyrings, etc.)."
  value       = google_assured_workloads_workload.workload.resources
}

output "folder_id" {
  description = "The GCP folder ID provisioned for the workload (the CONSUMER_FOLDER resource). Null if not provisioned."
  value = try(
    one([
      for r in google_assured_workloads_workload.workload.resources
      : r.resource_id
      if r.resource_type == "CONSUMER_FOLDER"
    ]),
    null
  )
}

output "project_ids" {
  description = "List of GCP project IDs provisioned for the workload."
  value = [
    for r in google_assured_workloads_workload.workload.resources
    : r.resource_id
    if r.resource_type == "CONSUMER_PROJECT"
  ]
}

output "kms_project_id" {
  description = "The encryption keys project ID provisioned for CMEK (if any)."
  value = try(
    one([
      for r in google_assured_workloads_workload.workload.resources
      : r.resource_id
      if r.resource_type == "ENCRYPTION_KEYS_PROJECT"
    ]),
    null
  )
}
