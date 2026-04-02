output "alert_policy_ids" {
  description = "Map of alert policy display name to resource name."
  value = merge(
    { for k, p in google_monitoring_alert_policy.custom : k => p.name },
    length(google_monitoring_alert_policy.high_cpu) > 0 ? {
      "high_cpu" = google_monitoring_alert_policy.high_cpu[0].name
    } : {},
    length(google_monitoring_alert_policy.high_memory) > 0 ? {
      "high_memory" = google_monitoring_alert_policy.high_memory[0].name
    } : {},
    length(google_monitoring_alert_policy.disk_usage) > 0 ? {
      "disk_usage" = google_monitoring_alert_policy.disk_usage[0].name
    } : {},
    length(google_monitoring_alert_policy.uptime_check) > 0 ? {
      "uptime_check" = google_monitoring_alert_policy.uptime_check[0].name
    } : {},
  )
}

output "dashboard_id" {
  description = "The resource ID of the monitoring dashboard, if created."
  value       = length(google_monitoring_dashboard.dashboard) > 0 ? google_monitoring_dashboard.dashboard[0].id : null
}

output "notification_channel_ids" {
  description = "Map of notification channel name to resource ID."
  value = {
    for name, ch in google_monitoring_notification_channel.channels : name => ch.id
  }
}

output "notification_channel_names" {
  description = "Map of notification channel name to resource name."
  value = {
    for name, ch in google_monitoring_notification_channel.channels : name => ch.name
  }
}
