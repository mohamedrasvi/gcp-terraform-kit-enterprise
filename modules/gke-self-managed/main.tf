terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}

resource "google_container_cluster" "cluster" {
  project  = var.project_id
  name     = var.name
  location = var.region

  deletion_protection = var.deletion_protection

  network    = var.network_self_link
  subnetwork = var.subnet_self_link

  # Create the cluster without any default node pool; node pools are managed
  # separately below for better lifecycle management.
  remove_default_node_pool = true
  initial_node_count       = 1

  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  private_cluster_config {
    enable_private_nodes    = var.enable_private_nodes
    enable_private_endpoint = var.enable_private_endpoint
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block

    master_global_access_config {
      enabled = var.master_global_access_enabled
    }
  }

  dynamic "master_authorized_networks_config" {
    for_each = length(var.master_authorized_networks) > 0 ? [1] : []
    content {
      dynamic "cidr_blocks" {
        for_each = var.master_authorized_networks
        content {
          cidr_block   = cidr_blocks.value.cidr_block
          display_name = lookup(cidr_blocks.value, "display_name", "")
        }
      }
    }
  }

  release_channel {
    channel = var.release_channel
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  binary_authorization {
    evaluation_mode = var.binary_authorization_mode
  }

  datapath_provider = "ADVANCED_DATAPATH"

  vertical_pod_autoscaling {
    enabled = true
  }

  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
    gce_persistent_disk_csi_driver_config {
      enabled = true
    }
    gcs_fuse_csi_driver_config {
      enabled = true
    }
    gcp_filestore_csi_driver_config {
      enabled = true
    }
  }

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS", "APISERVER", "SCHEDULER", "CONTROLLER_MANAGER"]
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS", "APISERVER", "SCHEDULER", "CONTROLLER_MANAGER", "STORAGE", "HPA", "POD", "DAEMONSET", "DEPLOYMENT", "STATEFULSET"]

    managed_prometheus {
      enabled = true
    }
  }

  resource_labels = var.labels

  lifecycle {
    ignore_changes = [initial_node_count]
  }
}

resource "google_container_node_pool" "node_pools" {
  for_each = { for pool in var.node_pools : pool.name => pool }

  project    = var.project_id
  name       = each.value.name
  location   = var.region
  cluster    = google_container_cluster.cluster.name

  # Use node_count or autoscaling based on whether min/max are set
  initial_node_count = lookup(each.value, "initial_node_count", each.value.min_count)

  autoscaling {
    min_node_count  = each.value.min_count
    max_node_count  = each.value.max_count
    location_policy = lookup(each.value, "location_policy", "BALANCED")
  }

  management {
    auto_repair  = lookup(each.value, "auto_repair", true)
    auto_upgrade = lookup(each.value, "auto_upgrade", true)
  }

  upgrade_settings {
    max_surge       = lookup(each.value, "max_surge", 1)
    max_unavailable = lookup(each.value, "max_unavailable", 0)
    strategy        = "SURGE"
  }

  node_config {
    machine_type    = each.value.machine_type
    disk_size_gb    = lookup(each.value, "disk_size_gb", 100)
    disk_type       = lookup(each.value, "disk_type", "pd-ssd")
    image_type      = lookup(each.value, "image_type", "COS_CONTAINERD")
    preemptible     = lookup(each.value, "preemptible", false)
    spot            = lookup(each.value, "spot", false)
    service_account = lookup(each.value, "service_account", null)

    # Use workload identity on each node
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    shielded_instance_config {
      enable_secure_boot          = lookup(each.value, "enable_secure_boot", true)
      enable_integrity_monitoring = lookup(each.value, "enable_integrity_monitoring", true)
    }

    labels = lookup(each.value, "labels", {})

    dynamic "taint" {
      for_each = lookup(each.value, "taints", [])
      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }

    oauth_scopes = lookup(each.value, "oauth_scopes", [
      "https://www.googleapis.com/auth/cloud-platform",
    ])

    tags = lookup(each.value, "tags", [])

    metadata = merge(
      { "disable-legacy-endpoints" = "true" },
      lookup(each.value, "metadata", {})
    )
  }

  lifecycle {
    ignore_changes = [initial_node_count]
  }
}
