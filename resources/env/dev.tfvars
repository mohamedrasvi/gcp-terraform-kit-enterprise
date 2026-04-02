project_id        = "myorg-nonprod-dev"
default_region    = "us-central1"
environment       = "dev"
network_self_link = "projects/myorg-nonprod-common/global/networks/nonprod-vpc"
labels            = { team = "platform" }

# ---------------------------------------------------------------------------
# Feature flags — enable only what is needed for this environment
# ---------------------------------------------------------------------------
enable_gke_autopilot      = true
enable_cloud_sql_postgres = true
enable_gcs_buckets        = true

# ---------------------------------------------------------------------------
# GKE Autopilot
# ---------------------------------------------------------------------------
gke_autopilot_config = {
  name                       = "dev-autopilot"
  subnet_self_link           = "projects/myorg-nonprod-common/regions/us-central1/subnetworks/public-subnet-1"
  pods_range_name            = "pods"
  services_range_name        = "services"
  master_ipv4_cidr_block     = "172.16.0.0/28"
  master_authorized_networks = []
  release_channel            = "REGULAR"
}

# ---------------------------------------------------------------------------
# Cloud SQL – PostgreSQL
# ---------------------------------------------------------------------------
cloud_sql_postgres_config = {
  instance_name     = "dev-postgres"
  database_version  = "POSTGRES_15"
  tier              = "db-custom-2-8192"
  disk_size         = 20
  availability_type = "ZONAL"
  database_name     = "app"
  backup_enabled    = true
  network_self_link = ""
}

# ---------------------------------------------------------------------------
# GCS Buckets
# ---------------------------------------------------------------------------
gcs_buckets = [
  {
    name               = "myorg-dev-data"
    location           = "US"
    storage_class      = "STANDARD"
    versioning_enabled = true
  }
]
