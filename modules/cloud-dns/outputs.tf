output "zone_name" {
  description = "The resource name of the managed DNS zone."
  value       = google_dns_managed_zone.zone.name
}

output "zone_id" {
  description = "The unique ID of the managed DNS zone."
  value       = google_dns_managed_zone.zone.id
}

output "dns_name" {
  description = "The DNS name of the managed zone."
  value       = google_dns_managed_zone.zone.dns_name
}

output "name_servers" {
  description = "The list of nameservers assigned to the managed zone. For public zones, delegate to these NS records at your registrar."
  value       = google_dns_managed_zone.zone.name_servers
}

output "visibility" {
  description = "The visibility (public or private) of the managed zone."
  value       = google_dns_managed_zone.zone.visibility
}

output "record_set_names" {
  description = "Map of record key (name-type) to the DNS name of each record set."
  value = {
    for k, r in google_dns_record_set.records : k => r.name
  }
}
