# ===========================================================================
# foundation/standard/main.tf
#
# Orchestrates the GCP landing zone: folders, projects, VPCs, monitoring,
# logging, org policies, and Terraform state buckets for the resources layer.
# Supports two networking modes controlled by var.vpc_mode:
#   - "shared"     : one Shared VPC host project per environment, service
#                    projects attached to it.
#   - "non-shared" : each project gets its own standalone VPC.
# ===========================================================================

locals {
  org_parent = "organizations/${var.org_id}"

  # -------------------------------------------------------------------------
  # Folder lookup helpers - map display name -> folder ID (numeric only)
  # -------------------------------------------------------------------------
  # folder_ids_by_name["Non-Production"] = "folders/123..."  (full resource id)
  # We strip the "folders/" prefix where project-factory expects a bare numeric id.
  folder_ids_by_name = module.env_folders.folder_ids # map of display_name -> "folders/<id>"

  # Map environment key -> folder numeric id (no "folders/" prefix)
  env_folder_numeric_id = {
    for env_key, env_cfg in var.environments :
    env_key => trimprefix(
      local.folder_ids_by_name[env_cfg.folder_display_name],
      "folders/"
    )
  }

  # =========================================================================
  # SHARED VPC mode locals
  # =========================================================================

  # Flat map: "<env>/<project_id>" -> { env, project_name, project_id, is_common, ... }
  # Common (host) projects
  shared_common_projects = var.vpc_mode == "shared" ? {
    for env_key, cfg in var.shared_vpc_config :
    "${env_key}/${cfg.common_project_id}" => {
      env          = env_key
      project_name = cfg.common_project_name
      project_id   = cfg.common_project_id
    }
  } : {}

  # Resource (service) projects - flatten list of lists
  shared_resource_projects = var.vpc_mode == "shared" ? {
    for item in flatten([
      for env_key, cfg in var.shared_vpc_config : [
        for proj in cfg.resource_projects : {
          key          = "${env_key}/${proj.project_id}"
          env          = env_key
          project_name = proj.project_name
          project_id   = proj.project_id
        }
      ]
    ]) : item.key => item
  } : {}

  # All projects in shared mode (common + resource)
  shared_all_projects = merge(local.shared_common_projects, local.shared_resource_projects)

  # Public subnets per env (shared mode) - flatten to a map keyed "<env>/<subnet_name>"
  shared_public_subnets = var.vpc_mode == "shared" ? {
    for item in flatten([
      for env_key, cfg in var.shared_vpc_config : [
        for sn in cfg.public_subnets : {
          key           = "${env_key}/${sn.name}"
          env           = env_key
          name          = sn.name
          region        = sn.region
          ip_cidr_range = sn.ip_cidr_range
          host_project  = cfg.common_project_id
        }
      ]
    ]) : item.key => item
  } : {}

  # Private subnets per env (shared mode)
  shared_private_subnets = var.vpc_mode == "shared" ? {
    for item in flatten([
      for env_key, cfg in var.shared_vpc_config : [
        for sn in cfg.private_subnets : {
          key           = "${env_key}/${sn.name}"
          env           = env_key
          name          = sn.name
          region        = sn.region
          ip_cidr_range = sn.ip_cidr_range
          host_project  = cfg.common_project_id
        }
      ]
    ]) : item.key => item
  } : {}

  # =========================================================================
  # NON-SHARED VPC mode locals
  # =========================================================================

  # Flat map: "<env>/<project_id>" -> project config
  non_shared_projects = var.vpc_mode == "non-shared" ? {
    for item in flatten([
      for env_key, env_cfg in var.non_shared_vpc_config : [
        for proj in env_cfg.projects : {
          key          = "${env_key}/${proj.project_id}"
          env          = env_key
          project_name = proj.project_name
          project_id   = proj.project_id
        }
      ]
    ]) : item.key => item
  } : {}

  # Non-shared public subnets: "<env>/<project_id>/<subnet_name>"
  non_shared_public_subnets = var.vpc_mode == "non-shared" ? {
    for item in flatten([
      for env_key, env_cfg in var.non_shared_vpc_config : [
        for proj in env_cfg.projects : [
          for sn in proj.public_subnets : {
            key           = "${env_key}/${proj.project_id}/${sn.name}"
            env           = env_key
            project_id    = proj.project_id
            name          = sn.name
            region        = sn.region
            ip_cidr_range = sn.ip_cidr_range
          }
        ]
      ]
    ]) : item.key => item
  } : {}

  # Non-shared private subnets
  non_shared_private_subnets = var.vpc_mode == "non-shared" ? {
    for item in flatten([
      for env_key, env_cfg in var.non_shared_vpc_config : [
        for proj in env_cfg.projects : [
          for sn in proj.private_subnets : {
            key           = "${env_key}/${proj.project_id}/${sn.name}"
            env           = env_key
            project_id    = proj.project_id
            name          = sn.name
            region        = sn.region
            ip_cidr_range = sn.ip_cidr_range
          }
        ]
      ]
    ]) : item.key => item
  } : {}

  # =========================================================================
  # Unified project list for state bucket creation
  # =========================================================================
  all_project_ids = var.vpc_mode == "shared" ? [
    for k, v in local.shared_all_projects : v.project_id
    ] : [
    for k, v in local.non_shared_projects : v.project_id
  ]
}

# ===========================================================================
# 1. Environment Folders
# ===========================================================================

module "env_folders" {
  source = "../../modules/folder-factory"

  parent = local.org_parent
  names  = [for env_key, env_cfg in var.environments : env_cfg.folder_display_name]
  labels = var.labels
}

# ===========================================================================
# 2a. SHARED VPC MODE - Projects
# ===========================================================================

# Common (Shared VPC host) projects - one per environment
module "shared_common_project" {
  for_each = local.shared_common_projects
  source   = "../../modules/project-factory"

  project_name    = each.value.project_name
  project_id      = each.value.project_id
  folder_id       = local.env_folder_numeric_id[each.value.env]
  billing_account = var.billing_account
  labels          = var.labels

  activate_apis = [
    "compute.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "storage.googleapis.com",
    "container.googleapis.com",
  ]
}

# Resource (service) projects attached to the Shared VPC
module "shared_resource_project" {
  for_each = local.shared_resource_projects
  source   = "../../modules/project-factory"

  project_name    = each.value.project_name
  project_id      = each.value.project_id
  folder_id       = local.env_folder_numeric_id[each.value.env]
  billing_account = var.billing_account
  labels          = var.labels

  activate_apis = [
    "compute.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "storage.googleapis.com",
    "container.googleapis.com",
  ]
}

# ===========================================================================
# 2b. SHARED VPC MODE - Networking
# ===========================================================================

# VPC network in each common (host) project
module "shared_vpc_network" {
  for_each = local.shared_common_projects
  source   = "../../modules/vpc"

  project_id   = each.value.project_id
  network_name = "vpc-${each.value.env}"
  routing_mode = "GLOBAL"

  depends_on = [module.shared_common_project]
}

# Public subnets (will have Cloud NAT attached)
module "shared_public_subnets" {
  for_each = local.shared_public_subnets
  source   = "../../modules/subnets"

  project_id        = each.value.host_project
  network_self_link = module.shared_vpc_network[each.value.env].network_self_link
  subnets = [{
    name                  = each.value.name
    region                = each.value.region
    ip_cidr_range         = each.value.ip_cidr_range
    private_google_access = false
    is_public             = true
  }]

  depends_on = [module.shared_vpc_network]
}

# Private subnets (no Cloud NAT)
module "shared_private_subnets" {
  for_each = local.shared_private_subnets
  source   = "../../modules/subnets"

  project_id        = each.value.host_project
  network_self_link = module.shared_vpc_network[each.value.env].network_self_link
  subnets = [{
    name                  = each.value.name
    region                = each.value.region
    ip_cidr_range         = each.value.ip_cidr_range
    private_google_access = true
    is_public             = false
  }]

  depends_on = [module.shared_vpc_network]
}

# Enable Shared VPC on the host project and attach service projects
module "shared_vpc_host" {
  for_each = var.vpc_mode == "shared" ? var.shared_vpc_config : {}
  source   = "../../modules/shared-vpc"

  host_project_id = each.value.common_project_id
  service_project_ids = [
    for proj in each.value.resource_projects : proj.project_id
  ]

  depends_on = [
    module.shared_common_project,
    module.shared_resource_project,
  ]
}

# Cloud NAT for public subnets - one router+NAT per (env, region) combination
locals {
  # Deduplicate: one NAT gateway per (host_project, region)
  shared_nat_keys = var.vpc_mode == "shared" ? {
    for item in distinct([
      for k, sn in local.shared_public_subnets : {
        key          = "${sn.env}/${sn.region}"
        env          = sn.env
        region       = sn.region
        host_project = sn.host_project
      }
    ]) : item.key => item
  } : {}
}

module "shared_cloud_nat" {
  for_each = local.shared_nat_keys
  source   = "../../modules/cloud-nat"

  project_id        = each.value.host_project
  region            = each.value.region
  network_self_link = module.shared_vpc_network[each.value.env].network_self_link
  nat_name          = "nat-${each.value.env}-${each.value.region}"
  router_name       = "router-${each.value.env}-${each.value.region}"

  depends_on = [module.shared_vpc_network]
}

# ===========================================================================
# 2c. SHARED VPC MODE - Monitoring & Logging
# ===========================================================================

# Central monitoring workspace in each common project scoped to the env folder
module "shared_monitoring" {
  for_each = var.vpc_mode == "shared" && var.enable_monitoring ? var.shared_vpc_config : {}
  source   = "../../modules/monitoring"

  project_id = each.value.common_project_id
  monitored_projects = [
    for proj in each.value.resource_projects : proj.project_id
  ]

  depends_on = [module.shared_common_project]
}

# Basic monitoring in each resource project (alerting policies, dashboards)
module "shared_resource_monitoring" {
  for_each = var.vpc_mode == "shared" && var.enable_monitoring ? local.shared_resource_projects : {}
  source   = "../../modules/monitoring"

  project_id = each.value.project_id

  depends_on = [module.shared_resource_project]
}

# Centralized logging in each common project with aggregated sinks
module "shared_logging" {
  for_each = var.vpc_mode == "shared" && var.enable_logging ? var.shared_vpc_config : {}
  source   = "../../modules/logging"

  project_id          = each.value.common_project_id
  log_bucket_location = var.resource_state_bucket_location

  depends_on = [module.shared_common_project]
}

# ===========================================================================
# 3a. NON-SHARED VPC MODE - Projects
# ===========================================================================

module "non_shared_project" {
  for_each = local.non_shared_projects
  source   = "../../modules/project-factory"

  project_name    = each.value.project_name
  project_id      = each.value.project_id
  folder_id       = local.env_folder_numeric_id[each.value.env]
  billing_account = var.billing_account
  labels          = var.labels

  activate_apis = [
    "compute.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "storage.googleapis.com",
    "container.googleapis.com",
  ]
}

# ===========================================================================
# 3b. NON-SHARED VPC MODE - Networking
# ===========================================================================

module "non_shared_vpc_network" {
  for_each = local.non_shared_projects
  source   = "../../modules/vpc"

  project_id   = each.value.project_id
  network_name = "vpc-${each.value.project_id}"
  routing_mode = "GLOBAL"

  depends_on = [module.non_shared_project]
}

module "non_shared_public_subnets" {
  for_each = local.non_shared_public_subnets
  source   = "../../modules/subnets"

  project_id        = each.value.project_id
  network_self_link = module.non_shared_vpc_network["${each.value.env}/${each.value.project_id}"].network_self_link
  subnets = [{
    name                  = each.value.name
    region                = each.value.region
    ip_cidr_range         = each.value.ip_cidr_range
    private_google_access = false
    is_public             = true
  }]

  depends_on = [module.non_shared_vpc_network]
}

module "non_shared_private_subnets" {
  for_each = local.non_shared_private_subnets
  source   = "../../modules/subnets"

  project_id        = each.value.project_id
  network_self_link = module.non_shared_vpc_network["${each.value.env}/${each.value.project_id}"].network_self_link
  subnets = [{
    name                  = each.value.name
    region                = each.value.region
    ip_cidr_range         = each.value.ip_cidr_range
    private_google_access = true
    is_public             = false
  }]

  depends_on = [module.non_shared_vpc_network]
}

# Cloud NAT per (project, region) for public subnets
locals {
  non_shared_nat_keys = var.vpc_mode == "non-shared" ? {
    for item in distinct([
      for k, sn in local.non_shared_public_subnets : {
        key        = "${sn.env}/${sn.project_id}/${sn.region}"
        env        = sn.env
        project_id = sn.project_id
        region     = sn.region
      }
    ]) : item.key => item
  } : {}
}

module "non_shared_cloud_nat" {
  for_each = local.non_shared_nat_keys
  source   = "../../modules/cloud-nat"

  project_id        = each.value.project_id
  region            = each.value.region
  network_self_link = module.non_shared_vpc_network["${each.value.env}/${each.value.project_id}"].network_self_link
  nat_name          = "nat-${each.value.project_id}-${each.value.region}"
  router_name       = "router-${each.value.project_id}-${each.value.region}"

  depends_on = [module.non_shared_vpc_network]
}

# ===========================================================================
# 3c. NON-SHARED VPC MODE - Monitoring & Logging
# ===========================================================================

module "non_shared_monitoring" {
  for_each = var.vpc_mode == "non-shared" && var.enable_monitoring ? local.non_shared_projects : {}
  source   = "../../modules/monitoring"

  project_id = each.value.project_id

  depends_on = [module.non_shared_project]
}

module "non_shared_logging" {
  for_each = var.vpc_mode == "non-shared" && var.enable_logging ? local.non_shared_projects : {}
  source   = "../../modules/logging"

  project_id          = each.value.project_id
  log_bucket_location = var.resource_state_bucket_location

  depends_on = [module.non_shared_project]
}

# ===========================================================================
# 4. GCS State Buckets for the Resources Layer
# ===========================================================================
# One bucket per project so the resources layer can store its state there.

module "resource_state_buckets" {
  for_each = toset(local.all_project_ids)
  source   = "../../modules/gcs-bucket"

  project_id                  = each.value
  name                        = "${each.value}-tfstate"
  location                    = var.resource_state_bucket_location
  storage_class               = "STANDARD"
  versioning_enabled          = true
  force_destroy               = false
  labels                      = var.labels
  uniform_bucket_level_access = true

  depends_on = [
    module.shared_common_project,
    module.shared_resource_project,
    module.non_shared_project,
  ]
}
