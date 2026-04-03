# ===========================================================================
# foundation/hipaa/main.tf
#
# Orchestrates the HIPAA-compliant GCP landing zone.
# Key difference from standard: Assured Workloads creates the compliance
# folder for each environment; projects are created inside that folder.
# ===========================================================================

locals {
  org_parent = "organizations/${var.org_id}"

  # -------------------------------------------------------------------------
  # Folder IDs from Assured Workloads (one folder per environment)
  # assured-workloads module outputs the folder_id created by the workload.
  # -------------------------------------------------------------------------
  aw_folder_ids = {
    for env_key, aw in module.assured_workloads :
    env_key => aw.folder_id # "folders/<id>"
  }

  # Bare numeric folder IDs for project-factory (no "folders/" prefix)
  env_folder_numeric_id = {
    for env_key, fid in local.aw_folder_ids :
    env_key => trimprefix(fid, "folders/")
  }

  # =========================================================================
  # SHARED VPC mode locals (identical logic to standard/)
  # =========================================================================

  shared_common_projects = var.vpc_mode == "shared" ? {
    for env_key, cfg in var.shared_vpc_config :
    "${env_key}/${cfg.common_project_id}" => {
      env          = env_key
      project_name = cfg.common_project_name
      project_id   = cfg.common_project_id
    }
  } : {}

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

  shared_all_projects = merge(local.shared_common_projects, local.shared_resource_projects)

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
  # NON-SHARED VPC mode locals (identical logic to standard/)
  # =========================================================================

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
# 2a. SHARED VPC MODE - Projects
# ===========================================================================

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
    "cloudkms.googleapis.com",
    "accesscontextmanager.googleapis.com",
  ]

  depends_on = [module.assured_workloads]
}

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
    "cloudkms.googleapis.com",
    "accesscontextmanager.googleapis.com",
  ]

  depends_on = [module.assured_workloads]
}

# ===========================================================================
# 2b. SHARED VPC MODE - Networking
# ===========================================================================

module "shared_vpc_network" {
  for_each = local.shared_common_projects
  source   = "../../modules/vpc"

  project_id   = each.value.project_id
  network_name = "vpc-${each.value.env}"
  routing_mode = "GLOBAL"

  depends_on = [module.shared_common_project]
}

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

locals {
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

module "shared_monitoring" {
  for_each = var.vpc_mode == "shared" && var.enable_monitoring ? var.shared_vpc_config : {}
  source   = "../../modules/monitoring"

  project_id = each.value.common_project_id
  monitored_projects = [
    for proj in each.value.resource_projects : proj.project_id
  ]

  depends_on = [module.shared_common_project]
}

module "shared_resource_monitoring" {
  for_each = var.vpc_mode == "shared" && var.enable_monitoring ? local.shared_resource_projects : {}
  source   = "../../modules/monitoring"

  project_id = each.value.project_id

  depends_on = [module.shared_resource_project]
}

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
    "cloudkms.googleapis.com",
    "accesscontextmanager.googleapis.com",
  ]

  depends_on = [module.assured_workloads]
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
# 4. Baseline Firewall Rules
# ===========================================================================

locals {
  baseline_firewall_rules = [
    {
      name        = "allow-iap-ssh-rdp"
      direction   = "INGRESS"
      description = "Allow SSH and RDP from Identity-Aware Proxy for secure access without public IPs."
      priority    = 1000
      ranges      = ["35.235.240.0/20"]
      allow = [
        { protocol = "tcp", ports = ["22", "3389"] }
      ]
    },
    {
      name        = "allow-gcp-health-checks"
      direction   = "INGRESS"
      description = "Allow GCP load balancer health check probes."
      priority    = 1000
      ranges      = ["35.191.0.0/16", "130.211.0.0/22"]
      allow = [
        { protocol = "tcp", ports = [] }
      ]
    },
    {
      name        = "allow-internal-rfc1918"
      direction   = "INGRESS"
      description = "Allow all internal traffic between RFC1918 ranges within the VPC."
      priority    = 1000
      ranges      = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
      allow = [
        { protocol = "tcp", ports = [] },
        { protocol = "udp", ports = [] },
        { protocol = "icmp", ports = [] }
      ]
    },
    {
      name        = "deny-all-ingress"
      direction   = "INGRESS"
      description = "Explicit deny-all ingress at lowest priority — defense in depth."
      priority    = 65534
      ranges      = ["0.0.0.0/0"]
      deny = [
        { protocol = "all", ports = [] }
      ]
    },
  ]
}

module "shared_vpc_firewall" {
  for_each = var.vpc_mode == "shared" ? local.shared_common_projects : {}
  source   = "../../modules/firewall"

  project_id        = each.value.project_id
  network_self_link = module.shared_vpc_network[each.key].network_self_link
  rules             = local.baseline_firewall_rules

  depends_on = [module.shared_vpc_network]
}

module "non_shared_vpc_firewall" {
  for_each = var.vpc_mode == "non-shared" ? local.non_shared_projects : {}
  source   = "../../modules/firewall"

  project_id        = each.value.project_id
  network_self_link = module.non_shared_vpc_network[each.key].network_self_link
  rules             = local.baseline_firewall_rules

  depends_on = [module.non_shared_vpc_network]
}

# ===========================================================================
# 5. GCS State Buckets for the Resources Layer
# ===========================================================================

module "resource_state_buckets" {
  for_each = toset(local.all_project_ids)
  source   = "../../modules/gcs-bucket"

  project_id                  = each.value
  name                        = "${each.value}-tfstate"
  location                    = var.resource_state_bucket_location
  storage_class               = "STANDARD"
  versioning_enabled          = true
  force_destroy               = false
  uniform_bucket_level_access = true
  labels = merge(var.labels, {
    compliance-regime = lower(var.compliance_regime)
  })

  depends_on = [
    module.shared_common_project,
    module.shared_resource_project,
    module.non_shared_project,
  ]
}
