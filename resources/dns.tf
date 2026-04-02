module "cloud_dns" {
  source = "../modules/cloud-dns"
  count  = var.enable_cloud_dns ? 1 : 0

  project_id        = var.project_id
  zone_name         = var.cloud_dns_config.zone_name
  dns_name          = var.cloud_dns_config.dns_name
  visibility        = var.cloud_dns_config.visibility
  private_visibility_networks = [var.network_self_link]
  record_sets       = var.cloud_dns_config.record_sets
  labels            = local.common_labels
}
