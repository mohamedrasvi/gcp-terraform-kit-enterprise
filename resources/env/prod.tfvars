project_id        = "myorg-prod-app"
default_region    = "us-central1"
environment       = "prod"
network_self_link = "projects/myorg-prod-common/global/networks/prod-vpc"
labels            = { team = "platform" }

# ---------------------------------------------------------------------------
# Feature flags
# ---------------------------------------------------------------------------
enable_gke_autopilot      = true
enable_cloud_sql_postgres = true
enable_gcs_buckets        = true
enable_artifact_registry  = true

# ---------------------------------------------------------------------------
# GKE Autopilot
# ---------------------------------------------------------------------------
gke_autopilot_config = {
  name                       = "prod-autopilot"
  subnet_self_link           = "projects/myorg-prod-common/regions/us-central1/subnetworks/public-subnet-1"
  pods_range_name            = "pods"
  services_range_name        = "services"
  master_ipv4_cidr_block     = "172.16.0.16/28"
  master_authorized_networks = []
  release_channel            = "STABLE"
}

# ---------------------------------------------------------------------------
# Cloud SQL – PostgreSQL (larger tier, HA REGIONAL)
# ---------------------------------------------------------------------------
cloud_sql_postgres_config = {
  instance_name     = "prod-postgres"
  database_version  = "POSTGRES_15"
  tier              = "db-custom-4-16384"
  disk_size         = 100
  availability_type = "REGIONAL"
  database_name     = "app"
  backup_enabled    = true
  network_self_link = ""
}

# ---------------------------------------------------------------------------
# GCS Buckets
# ---------------------------------------------------------------------------
gcs_buckets = [
  {
    name               = "myorg-prod-data"
    location           = "US"
    storage_class      = "STANDARD"
    versioning_enabled = true
  }
]

# ---------------------------------------------------------------------------
# Artifact Registry
# ---------------------------------------------------------------------------
artifact_registry_config = {
  repository_id = "prod-docker"
  format        = "DOCKER"
  location      = "us-central1"
  description   = "Production Docker images"
}
