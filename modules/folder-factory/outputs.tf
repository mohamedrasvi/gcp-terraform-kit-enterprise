output "folder_ids" {
  description = "A map of folder display name to fully-qualified folder resource ID (folders/<id>)."
  value = {
    for name, folder in google_folder.folders :
    name => folder.id
  }
}

output "folder_names" {
  description = "A map of folder display name to the folder resource name (e.g. folders/123456789)."
  value = {
    for name, folder in google_folder.folders :
    name => folder.name
  }
}

output "folder_display_names" {
  description = "List of all folder display names created by this module."
  value       = [for folder in google_folder.folders : folder.display_name]
}
