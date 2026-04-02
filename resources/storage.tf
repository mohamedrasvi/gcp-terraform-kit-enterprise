module "gcs_buckets" {
  source   = "../modules/gcs-bucket"
  for_each = var.enable_gcs_buckets ? { for b in var.gcs_buckets : b.name => b } : {}

  project_id         = var.project_id
  name               = each.value.name
  location           = each.value.location
  storage_class      = each.value.storage_class
  versioning_enabled = each.value.versioning_enabled
  labels             = local.common_labels
}
