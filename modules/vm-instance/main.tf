terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

resource "google_compute_instance" "vm" {
  project      = var.project_id
  name         = var.name
  zone         = var.zone
  machine_type = var.machine_type
  labels       = var.labels
  tags         = var.tags

  # Metadata including SSH keys and startup scripts
  metadata = merge(
    var.metadata,
    { "block-project-ssh-keys" = tostring(var.block_project_ssh_keys) }
  )

  boot_disk {
    initialize_params {
      image  = var.boot_disk_image
      size   = var.boot_disk_size
      type   = var.boot_disk_type
      labels = var.labels
    }
    auto_delete = var.boot_disk_auto_delete
  }

  network_interface {
    network    = var.network_self_link
    subnetwork = var.subnet_self_link

    # Only create an external access config if explicitly requested.
    # Default is no external IP for security best practices.
    dynamic "access_config" {
      for_each = var.enable_external_ip ? [1] : []
      content {
        # Leaving nat_ip empty causes GCP to use an ephemeral external IP.
        # For production, assign a static external IP via google_compute_address.
        nat_ip = var.external_ip_address
      }
    }
  }

  service_account {
    email  = var.service_account_email
    scopes = var.service_account_scopes
  }

  shielded_instance_config {
    enable_secure_boot          = var.enable_secure_boot
    enable_vtpm                 = var.enable_vtpm
    enable_integrity_monitoring = var.enable_integrity_monitoring
  }

  scheduling {
    on_host_maintenance = var.preemptible || var.spot ? "TERMINATE" : "MIGRATE"
    automatic_restart   = var.preemptible || var.spot ? false : true
    preemptible         = var.preemptible
    provisioning_model  = var.spot ? "SPOT" : "STANDARD"
  }

  # Prevent accidental deletion/replacement in production
  allow_stopping_for_update = var.allow_stopping_for_update

  lifecycle {
    ignore_changes = [
      metadata["ssh-keys"],
    ]
  }
}
