module "bigquery" {
  source = "../modules/bigquery"
  count  = var.enable_bigquery ? 1 : 0

  project_id = var.project_id
  dataset_id = var.bigquery_config.dataset_id
  location   = var.bigquery_config.location
  tables     = var.bigquery_config.tables
  labels     = local.common_labels
}
