module "artifact_registry" {
  source = "../modules/artifact-registry"
  count  = var.enable_artifact_registry ? 1 : 0

  project_id    = var.project_id
  repository_id = var.artifact_registry_config.repository_id
  format        = var.artifact_registry_config.format
  location      = var.artifact_registry_config.location
  description   = var.artifact_registry_config.description
  labels        = local.common_labels
}
