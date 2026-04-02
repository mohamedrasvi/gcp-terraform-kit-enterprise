module "vm_instances" {
  source   = "../modules/vm-instance"
  for_each = var.enable_vm_instances ? { for vm in var.vm_instances : vm.name => vm } : {}

  project_id            = var.project_id
  name                  = each.value.name
  zone                  = each.value.zone
  machine_type          = each.value.machine_type
  boot_disk_image       = each.value.boot_disk_image
  boot_disk_size        = each.value.boot_disk_size
  network_self_link     = var.network_self_link
  subnet_self_link      = each.value.subnet_self_link
  service_account_email = each.value.service_account_email
  tags                  = each.value.tags
  labels                = merge(local.common_labels, each.value.labels)
}
