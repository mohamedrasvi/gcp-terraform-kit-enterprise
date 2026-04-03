# Shared private service connection — one per VPC, shared by all Cloud SQL instances.
# GCP only allows one servicenetworking.googleapis.com peering per VPC network.
module "sql_private_connection" {
  source = "../modules/sql-private-connection"
  count  = (var.enable_cloud_sql_postgres || var.enable_cloud_sql_mysql) ? 1 : 0

  project_id        = var.project_id
  name              = "sql-${var.project_id}"
  network_self_link = var.network_self_link
}

module "cloud_sql_postgres" {
  source = "../modules/cloud-sql-postgres"
  count  = var.enable_cloud_sql_postgres ? 1 : 0

  project_id            = var.project_id
  private_connection_id = module.sql_private_connection[0].connection_id
  instance_name         = var.cloud_sql_postgres_config.instance_name
  database_version      = var.cloud_sql_postgres_config.database_version
  region                = var.default_region
  tier                  = var.cloud_sql_postgres_config.tier
  disk_size             = var.cloud_sql_postgres_config.disk_size
  availability_type     = var.cloud_sql_postgres_config.availability_type
  database_name         = var.cloud_sql_postgres_config.database_name
  backup_enabled        = var.cloud_sql_postgres_config.backup_enabled
  network_self_link     = var.network_self_link
  deletion_protection   = var.environment == "prod" ? true : false
  labels                = local.common_labels
}

module "cloud_sql_mysql" {
  source = "../modules/cloud-sql-mysql"
  count  = var.enable_cloud_sql_mysql ? 1 : 0

  project_id            = var.project_id
  private_connection_id = module.sql_private_connection[0].connection_id
  instance_name         = var.cloud_sql_mysql_config.instance_name
  database_version      = var.cloud_sql_mysql_config.database_version
  region                = var.default_region
  tier                  = var.cloud_sql_mysql_config.tier
  disk_size             = var.cloud_sql_mysql_config.disk_size
  availability_type     = var.cloud_sql_mysql_config.availability_type
  database_name         = var.cloud_sql_mysql_config.database_name
  backup_enabled        = var.cloud_sql_mysql_config.backup_enabled
  network_self_link     = var.network_self_link
  deletion_protection   = var.environment == "prod" ? true : false
  labels                = local.common_labels
}
