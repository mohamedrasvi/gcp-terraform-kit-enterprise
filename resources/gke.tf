module "gke_autopilot" {
  source = "../modules/gke-autopilot"
  count  = var.enable_gke_autopilot ? 1 : 0

  project_id                 = var.project_id
  name                       = var.gke_autopilot_config.name
  region                     = var.default_region
  network_self_link          = var.network_self_link
  subnet_self_link           = var.gke_autopilot_config.subnet_self_link
  pods_range_name            = var.gke_autopilot_config.pods_range_name
  services_range_name        = var.gke_autopilot_config.services_range_name
  master_ipv4_cidr_block     = var.gke_autopilot_config.master_ipv4_cidr_block
  master_authorized_networks = var.gke_autopilot_config.master_authorized_networks
  release_channel            = var.gke_autopilot_config.release_channel
  deletion_protection        = var.environment == "prod" ? true : false
  labels                     = local.common_labels
}

module "gke_self_managed" {
  source = "../modules/gke-self-managed"
  count  = var.enable_gke_self_managed ? 1 : 0

  project_id                 = var.project_id
  name                       = var.gke_self_managed_config.name
  region                     = var.default_region
  network_self_link          = var.network_self_link
  subnet_self_link           = var.gke_self_managed_config.subnet_self_link
  pods_range_name            = var.gke_self_managed_config.pods_range_name
  services_range_name        = var.gke_self_managed_config.services_range_name
  master_ipv4_cidr_block     = var.gke_self_managed_config.master_ipv4_cidr_block
  node_pools                 = var.gke_self_managed_config.node_pools
  enable_private_nodes       = true
  deletion_protection        = var.environment == "prod" ? true : false
  labels                     = local.common_labels
}
