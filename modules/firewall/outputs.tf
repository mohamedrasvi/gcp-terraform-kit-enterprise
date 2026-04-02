output "firewall_rule_ids" {
  description = "Map of firewall rule name to resource ID."
  value = {
    for name, rule in google_compute_firewall.rules :
    name => rule.id
  }
}

output "firewall_rule_self_links" {
  description = "Map of firewall rule name to self-link URI."
  value = {
    for name, rule in google_compute_firewall.rules :
    name => rule.self_link
  }
}

output "firewall_rule_names" {
  description = "List of all firewall rule names created."
  value       = [for rule in google_compute_firewall.rules : rule.name]
}
