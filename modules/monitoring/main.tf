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
# Notification channels
# ---------------------------------------------------------------------------

resource "google_monitoring_notification_channel" "channels" {
  for_each = { for ch in var.notification_channels : ch.name => ch }

  project      = var.project_id
  display_name = each.value.display_name
  type         = each.value.type
  labels       = each.value.labels
  enabled      = lookup(each.value, "enabled", true)

  dynamic "sensitive_labels" {
    for_each = lookup(each.value, "auth_token", null) != null ? [1] : []
    content {
      auth_token = each.value.auth_token
    }
  }
}

# ---------------------------------------------------------------------------
# Default built-in alert policies
# ---------------------------------------------------------------------------

resource "google_monitoring_alert_policy" "high_cpu" {
  count = var.enable_default_policies ? 1 : 0

  project      = var.project_id
  display_name = "High CPU Utilization"
  combiner     = "OR"
  enabled      = true

  notification_channels = [for ch in google_monitoring_notification_channel.channels : ch.id]

  conditions {
    display_name = "CPU utilization > ${var.cpu_utilization_threshold * 100}%"
    condition_threshold {
      filter          = "resource.type = \"gce_instance\" AND metric.type = \"compute.googleapis.com/instance/cpu/utilization\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = var.cpu_utilization_threshold

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }

      trigger {
        count = 1
      }
    }
  }

  alert_strategy {
    auto_close = "1800s"
  }

  documentation {
    content   = "CPU utilization has exceeded ${var.cpu_utilization_threshold * 100}% for more than 5 minutes. Investigate running workloads and consider scaling up."
    mime_type = "text/markdown"
  }
}

resource "google_monitoring_alert_policy" "high_memory" {
  count = var.enable_default_policies ? 1 : 0

  project      = var.project_id
  display_name = "High Memory Utilization"
  combiner     = "OR"
  enabled      = true

  notification_channels = [for ch in google_monitoring_notification_channel.channels : ch.id]

  conditions {
    display_name = "Memory utilization > ${var.memory_utilization_threshold * 100}%"
    condition_threshold {
      filter          = "resource.type = \"gce_instance\" AND metric.type = \"agent.googleapis.com/memory/percent_used\" AND metric.labels.state = \"used\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = var.memory_utilization_threshold * 100 # Ops Agent returns 0-100

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }

      trigger {
        count = 1
      }
    }
  }

  alert_strategy {
    auto_close = "1800s"
  }

  documentation {
    content   = "Memory utilization has exceeded ${var.memory_utilization_threshold * 100}% for more than 5 minutes. Consider increasing instance memory or optimizing application memory usage."
    mime_type = "text/markdown"
  }
}

resource "google_monitoring_alert_policy" "disk_usage" {
  count = var.enable_default_policies ? 1 : 0

  project      = var.project_id
  display_name = "High Disk Usage"
  combiner     = "OR"
  enabled      = true

  notification_channels = [for ch in google_monitoring_notification_channel.channels : ch.id]

  conditions {
    display_name = "Disk usage > ${var.disk_usage_threshold * 100}%"
    condition_threshold {
      filter          = "resource.type = \"gce_instance\" AND metric.type = \"agent.googleapis.com/disk/percent_used\" AND metric.labels.state = \"used\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = var.disk_usage_threshold * 100 # Ops Agent returns 0-100

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }

      trigger {
        count = 1
      }
    }
  }

  alert_strategy {
    auto_close = "3600s"
  }

  documentation {
    content   = "Disk usage has exceeded ${var.disk_usage_threshold * 100}%. Consider cleaning up unused files or expanding disk capacity."
    mime_type = "text/markdown"
  }
}

resource "google_monitoring_alert_policy" "uptime_check" {
  count = var.enable_default_policies && length(var.uptime_check_ids) > 0 ? 1 : 0

  project      = var.project_id
  display_name = "Uptime Check Failures"
  combiner     = "OR"
  enabled      = true

  notification_channels = [for ch in google_monitoring_notification_channel.channels : ch.id]

  conditions {
    display_name = "Uptime check failure"
    condition_threshold {
      filter          = "resource.type = \"uptime_url\" AND metric.type = \"monitoring.googleapis.com/uptime_check/check_passed\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 1

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_NEXT_OLDER"
        cross_series_reducer = "REDUCE_COUNT_FALSE"
        group_by_fields      = ["resource.labels.host"]
      }

      trigger {
        count = 1
      }
    }
  }

  alert_strategy {
    auto_close = "1800s"
  }

  documentation {
    content   = "An uptime check has failed. The service may be unavailable. Investigate immediately."
    mime_type = "text/markdown"
  }
}

# ---------------------------------------------------------------------------
# Custom alert policies
# ---------------------------------------------------------------------------

resource "google_monitoring_alert_policy" "custom" {
  for_each = { for p in var.alert_policies : p.display_name => p }

  project      = var.project_id
  display_name = each.value.display_name
  combiner     = lookup(each.value, "combiner", "OR")
  enabled      = lookup(each.value, "enabled", true)

  notification_channels = concat(
    [for ch in google_monitoring_notification_channel.channels : ch.id],
    lookup(each.value, "additional_notification_channels", [])
  )

  dynamic "conditions" {
    for_each = each.value.conditions
    content {
      display_name = conditions.value.display_name

      dynamic "condition_threshold" {
        for_each = lookup(conditions.value, "condition_threshold", null) != null ? [conditions.value.condition_threshold] : []
        content {
          filter          = condition_threshold.value.filter
          duration        = condition_threshold.value.duration
          comparison      = condition_threshold.value.comparison
          threshold_value = condition_threshold.value.threshold_value

          aggregations {
            alignment_period     = lookup(condition_threshold.value, "alignment_period", "60s")
            per_series_aligner   = lookup(condition_threshold.value, "per_series_aligner", "ALIGN_MEAN")
            cross_series_reducer = lookup(condition_threshold.value, "cross_series_reducer", null)
            group_by_fields      = lookup(condition_threshold.value, "group_by_fields", [])
          }

          trigger {
            count   = lookup(condition_threshold.value, "trigger_count", 1)
            percent = lookup(condition_threshold.value, "trigger_percent", null)
          }
        }
      }
    }
  }

  dynamic "documentation" {
    for_each = lookup(each.value, "documentation", null) != null ? [each.value.documentation] : []
    content {
      content   = documentation.value.content
      mime_type = lookup(documentation.value, "mime_type", "text/markdown")
    }
  }
}

# ---------------------------------------------------------------------------
# Monitoring dashboard
# ---------------------------------------------------------------------------

resource "google_monitoring_dashboard" "dashboard" {
  count = var.create_dashboard ? 1 : 0

  project        = var.project_id
  dashboard_json = var.dashboard_json != null ? var.dashboard_json : jsonencode({
    displayName = var.dashboard_display_name
    gridLayout = {
      columns = "2"
      widgets = [
        {
          title = "CPU Utilization"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "resource.type = \"gce_instance\" AND metric.type = \"compute.googleapis.com/instance/cpu/utilization\""
                  aggregation = {
                    alignmentPeriod  = "60s"
                    perSeriesAligner = "ALIGN_MEAN"
                  }
                }
              }
            }]
          }
        },
        {
          title = "Memory Utilization"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "resource.type = \"gce_instance\" AND metric.type = \"agent.googleapis.com/memory/percent_used\""
                  aggregation = {
                    alignmentPeriod  = "60s"
                    perSeriesAligner = "ALIGN_MEAN"
                  }
                }
              }
            }]
          }
        }
      ]
    }
  })
}

# ---------------------------------------------------------------------------
# Monitored project attachments (folder-wide monitoring)
# ---------------------------------------------------------------------------

resource "google_monitoring_monitored_project" "monitored" {
  for_each = toset(var.monitored_projects)

  metrics_scope = "locations/global/metricsScopes/${var.project_id}"
  name          = "locations/global/metricsScopes/${var.project_id}/projects/${each.value}"
}
