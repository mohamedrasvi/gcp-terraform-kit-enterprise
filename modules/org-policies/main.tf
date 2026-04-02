terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0.0"
    }
  }
}

locals {
  # Determine whether policies are applied at org or folder level
  apply_at_org    = var.org_id != null && var.org_id != ""
  parent_resource = local.apply_at_org ? "organizations/${var.org_id}" : null

  # Build list of folder parents for folder-level policies
  folder_parents = [for fid in var.folder_ids : "folders/${fid}"]
}

# ---------------------------------------------------------------------------
# Boolean enforcement policies (org-level)
# ---------------------------------------------------------------------------

resource "google_org_policy_policy" "disable_serial_port" {
  count  = local.apply_at_org && var.disable_serial_port ? 1 : 0
  name   = "${local.parent_resource}/policies/compute.disableSerialPortAccess"
  parent = local.parent_resource

  spec {
    rules {
      enforce = "TRUE"
    }
  }
}

resource "google_org_policy_policy" "disable_sa_key_creation" {
  count  = local.apply_at_org && var.disable_service_account_key_creation ? 1 : 0
  name   = "${local.parent_resource}/policies/iam.disableServiceAccountKeyCreation"
  parent = local.parent_resource

  spec {
    rules {
      enforce = "TRUE"
    }
  }
}

resource "google_org_policy_policy" "require_shielded_vm" {
  count  = local.apply_at_org && var.require_shielded_vm ? 1 : 0
  name   = "${local.parent_resource}/policies/compute.requireShieldedVm"
  parent = local.parent_resource

  spec {
    rules {
      enforce = "TRUE"
    }
  }
}

resource "google_org_policy_policy" "uniform_bucket_level_access" {
  count  = local.apply_at_org && var.uniform_bucket_level_access ? 1 : 0
  name   = "${local.parent_resource}/policies/storage.uniformBucketLevelAccess"
  parent = local.parent_resource

  spec {
    rules {
      enforce = "TRUE"
    }
  }
}

# ---------------------------------------------------------------------------
# Deny all external IPs for Compute VMs
# ---------------------------------------------------------------------------

resource "google_org_policy_policy" "vm_external_ip_access" {
  count  = local.apply_at_org && var.deny_vm_external_ip ? 1 : 0
  name   = "${local.parent_resource}/policies/compute.vmExternalIpAccess"
  parent = local.parent_resource

  spec {
    rules {
      deny_all = "TRUE"
    }
  }
}

# ---------------------------------------------------------------------------
# Domain-restricted sharing (allowedPolicyMemberDomains)
# ---------------------------------------------------------------------------

resource "google_org_policy_policy" "domain_restricted_sharing" {
  count  = local.apply_at_org && length(var.domain_restricted_sharing_domains) > 0 ? 1 : 0
  name   = "${local.parent_resource}/policies/iam.allowedPolicyMemberDomains"
  parent = local.parent_resource

  spec {
    rules {
      values {
        allowed_values = var.domain_restricted_sharing_domains
      }
    }
  }
}

# ---------------------------------------------------------------------------
# Restrict Load Balancer types (optional)
# ---------------------------------------------------------------------------

resource "google_org_policy_policy" "restrict_lb_types" {
  count  = local.apply_at_org && length(var.allowed_load_balancer_types) > 0 ? 1 : 0
  name   = "${local.parent_resource}/policies/compute.restrictLoadBalancerCreationForTypes"
  parent = local.parent_resource

  spec {
    rules {
      values {
        allowed_values = var.allowed_load_balancer_types
      }
    }
  }
}

# ---------------------------------------------------------------------------
# Folder-level: disable serial port access
# ---------------------------------------------------------------------------

resource "google_org_policy_policy" "folder_disable_serial_port" {
  for_each = var.disable_serial_port ? toset(local.folder_parents) : toset([])

  name   = "${each.value}/policies/compute.disableSerialPortAccess"
  parent = each.value

  spec {
    rules {
      enforce = "TRUE"
    }
  }
}

resource "google_org_policy_policy" "folder_require_shielded_vm" {
  for_each = var.require_shielded_vm ? toset(local.folder_parents) : toset([])

  name   = "${each.value}/policies/compute.requireShieldedVm"
  parent = each.value

  spec {
    rules {
      enforce = "TRUE"
    }
  }
}

resource "google_org_policy_policy" "folder_vm_external_ip_access" {
  for_each = var.deny_vm_external_ip ? toset(local.folder_parents) : toset([])

  name   = "${each.value}/policies/compute.vmExternalIpAccess"
  parent = each.value

  spec {
    rules {
      deny_all = "TRUE"
    }
  }
}
