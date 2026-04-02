# ===========================================================================
# foundation/hipaa/org-policies.tf
#
# Applies org policies for HIPAA compliance. Extends the standard baseline
# with CMEK enforcement and Access Transparency requirements via additional
# google_org_policy_policy resources at the org level.
# ===========================================================================

locals {
  domain_restricted_sharing_domains = var.domain != "" ? [
    "is:domain:${var.domain}"
  ] : []

  # Collect Assured Workloads folder IDs for folder-level policy reinforcement
  all_aw_folder_ids = [
    for env_key, fid in local.aw_folder_ids :
    trimprefix(fid, "folders/")
  ]
}

# ---------------------------------------------------------------------------
# Standard baseline policies (same as standard/)
# ---------------------------------------------------------------------------

module "org_policies" {
  source = "../../modules/org-policies"

  org_id     = var.org_id
  folder_ids = local.all_aw_folder_ids

  disable_serial_port                  = true
  disable_service_account_key_creation = true
  require_shielded_vm                  = true
  uniform_bucket_level_access          = true
  deny_vm_external_ip                  = false

  domain_restricted_sharing_domains = local.domain_restricted_sharing_domains
  allowed_load_balancer_types        = []

  depends_on = [module.assured_workloads]
}

# ---------------------------------------------------------------------------
# HIPAA: Require CMEK for Cloud Storage
# Applied at org level so all HIPAA folders inherit it.
# ---------------------------------------------------------------------------

resource "google_org_policy_policy" "require_cmek_storage" {
  count  = var.enable_cmek ? 1 : 0
  name   = "organizations/${var.org_id}/policies/gcp.restrictCloudStorageForCMEK"
  parent = "organizations/${var.org_id}"

  spec {
    rules {
      enforce = "TRUE"
    }
  }
}

# ---------------------------------------------------------------------------
# HIPAA: Require CMEK for BigQuery
# ---------------------------------------------------------------------------

resource "google_org_policy_policy" "require_cmek_bigquery" {
  count  = var.enable_cmek ? 1 : 0
  name   = "organizations/${var.org_id}/policies/gcp.restrictCloudBigQueryForCMEK"
  parent = "organizations/${var.org_id}"

  spec {
    rules {
      enforce = "TRUE"
    }
  }
}

# ---------------------------------------------------------------------------
# HIPAA: Require CMEK for Compute persistent disks
# ---------------------------------------------------------------------------

resource "google_org_policy_policy" "require_cmek_compute" {
  count  = var.enable_cmek ? 1 : 0
  name   = "organizations/${var.org_id}/policies/compute.restrictCloudComputeForCMEK"
  parent = "organizations/${var.org_id}"

  spec {
    rules {
      enforce = "TRUE"
    }
  }
}

# ---------------------------------------------------------------------------
# HIPAA: Access Transparency - require admin activity logging
# ---------------------------------------------------------------------------

resource "google_org_policy_policy" "require_access_transparency" {
  count  = var.enable_access_transparency ? 1 : 0
  name   = "organizations/${var.org_id}/policies/gcp.accessTransparencyRenewal"
  parent = "organizations/${var.org_id}"

  spec {
    rules {
      enforce = "TRUE"
    }
  }
}

# ---------------------------------------------------------------------------
# HIPAA: Restrict allowed locations for data residency
# Only allow resources to be created in regions matching the configured
# Assured Workloads location.
# ---------------------------------------------------------------------------

resource "google_org_policy_policy" "restrict_resource_locations" {
  name   = "organizations/${var.org_id}/policies/gcp.resourceLocations"
  parent = "organizations/${var.org_id}"

  spec {
    rules {
      values {
        allowed_values = [
          "in:us-locations",
        ]
      }
    }
  }
}

# ---------------------------------------------------------------------------
# HIPAA: Disable public access prevention override for GCS
# (pairs with uniform bucket-level access)
# ---------------------------------------------------------------------------

resource "google_org_policy_policy" "public_access_prevention" {
  name   = "organizations/${var.org_id}/policies/storage.publicAccessPrevention"
  parent = "organizations/${var.org_id}"

  spec {
    rules {
      enforce = "TRUE"
    }
  }
}
