module "cloud_sql_postgres" {
  source = "../modules/cloud-sql-postgres"
  count  = var.enable_cloud_sql_postgres ? 1 : 0

  project_id        = var.project_id
  instance_name     = var.cloud_sql_postgres_config.instance_name
  database_version  = var.cloud_sql_postgres_config.database_version
  region            = var.default_region
  tier              = var.cloud_sql_postgres_config.tier
  disk_size         = var.cloud_sql_postgres_config.disk_size
  availability_type = var.cloud_sql_postgres_config.availability_type
  database_name     = var.cloud_sql_postgres_config.database_name
  backup_enabled    = var.cloud_sql_postgres_config.backup_enabled
  network_self_link = var.cloud_sql_postgres_config.network_self_link != "" ? var.cloud_sql_postgres_config.network_self_link : var.network_self_link
  deletion_protection = var.environment == "prod" ? true : false
  labels            = local.common_labels
}

module "cloud_sql_mysql" {
  source = "../modules/cloud-sql-mysql"
  count  = var.enable_cloud_sql_mysql ? 1 : 0

  project_id        = var.project_id
  instance_name     = var.cloud_sql_mysql_config.instance_name
  database_version  = var.cloud_sql_mysql_config.database_version
  region            = var.default_region
  tier              = var.cloud_sql_mysql_config.tier
  disk_size         = var.cloud_sql_mysql_config.disk_size
  availability_type = var.cloud_sql_mysql_config.availability_type
  database_name     = var.cloud_sql_mysql_config.database_name
  backup_enabled    = var.cloud_sql_mysql_config.backup_enabled
  network_self_link = var.cloud_sql_mysql_config.network_self_link != "" ? var.cloud_sql_mysql_config.network_self_link : var.network_self_link
  deletion_protection = var.environment == "prod" ? true : false
  labels            = local.common_labels
}
