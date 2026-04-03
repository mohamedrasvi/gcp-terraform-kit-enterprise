terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}

# ---------------------------------------------------------------------------
# VPC Service Controls — restricts data exfiltration from sensitive projects.
# Required for HIPAA compliance to prevent data leaving the perimeter.
#
# IMPORTANT: Requires an existing Access Policy at org level.
# Create one with: gcloud access-context-manager policies create --organization=ORG_ID --title="My Policy"
# Then pass the numeric policy ID as access_policy_id.
# ---------------------------------------------------------------------------

resource "google_access_context_manager_service_perimeter" "perimeter" {
  parent = "accessPolicies/${var.access_policy_id}"
  name   = "accessPolicies/${var.access_policy_id}/servicePerimeters/${var.perimeter_name}"
  title  = var.perimeter_title

  perimeter_type = var.perimeter_type

  # Use spec (dry-run) or status (enforced) based on var.dry_run
  dynamic "spec" {
    for_each = var.dry_run ? [1] : []
    content {
      resources           = var.protected_projects
      restricted_services = var.restricted_services

      vpc_accessible_services {
        enable_restriction = true
        allowed_services   = var.vpc_allowed_services
      }

      dynamic "ingress_policies" {
        for_each = var.ingress_policies
        content {
          ingress_from {
            identity_type = lookup(ingress_policies.value.from, "identity_type", null)
            identities    = lookup(ingress_policies.value.from, "identities", [])
            dynamic "sources" {
              for_each = lookup(ingress_policies.value.from, "access_level_sources", [])
              content {
                access_level = sources.value
              }
            }
          }
          ingress_to {
            resources = lookup(ingress_policies.value.to, "resources", ["*"])
            dynamic "operations" {
              for_each = lookup(ingress_policies.value.to, "operations", [])
              content {
                service_name = operations.value.service_name
                dynamic "method_selectors" {
                  for_each = lookup(operations.value, "methods", [])
                  content {
                    method = method_selectors.value
                  }
                }
              }
            }
          }
        }
      }

      dynamic "egress_policies" {
        for_each = var.egress_policies
        content {
          egress_from {
            identity_type = lookup(egress_policies.value.from, "identity_type", null)
            identities    = lookup(egress_policies.value.from, "identities", [])
          }
          egress_to {
            resources = lookup(egress_policies.value.to, "resources", ["*"])
            dynamic "operations" {
              for_each = lookup(egress_policies.value.to, "operations", [])
              content {
                service_name = operations.value.service_name
                dynamic "method_selectors" {
                  for_each = lookup(operations.value, "methods", [])
                  content {
                    method = method_selectors.value
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  dynamic "status" {
    for_each = var.dry_run ? [] : [1]
    content {
      resources           = var.protected_projects
      restricted_services = var.restricted_services

      vpc_accessible_services {
        enable_restriction = true
        allowed_services   = var.vpc_allowed_services
      }

      dynamic "ingress_policies" {
        for_each = var.ingress_policies
        content {
          ingress_from {
            identity_type = lookup(ingress_policies.value.from, "identity_type", null)
            identities    = lookup(ingress_policies.value.from, "identities", [])
            dynamic "sources" {
              for_each = lookup(ingress_policies.value.from, "access_level_sources", [])
              content {
                access_level = sources.value
              }
            }
          }
          ingress_to {
            resources = lookup(ingress_policies.value.to, "resources", ["*"])
            dynamic "operations" {
              for_each = lookup(ingress_policies.value.to, "operations", [])
              content {
                service_name = operations.value.service_name
                dynamic "method_selectors" {
                  for_each = lookup(operations.value, "methods", [])
                  content {
                    method = method_selectors.value
                  }
                }
              }
            }
          }
        }
      }

      dynamic "egress_policies" {
        for_each = var.egress_policies
        content {
          egress_from {
            identity_type = lookup(egress_policies.value.from, "identity_type", null)
            identities    = lookup(egress_policies.value.from, "identities", [])
          }
          egress_to {
            resources = lookup(egress_policies.value.to, "resources", ["*"])
            dynamic "operations" {
              for_each = lookup(egress_policies.value.to, "operations", [])
              content {
                service_name = operations.value.service_name
                dynamic "method_selectors" {
                  for_each = lookup(operations.value, "methods", [])
                  content {
                    method = method_selectors.value
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  use_explicit_dry_run_spec = var.dry_run
}
