output "resource_group_name" {
  description = "Resource group name"
  value       = azurerm_resource_group.main.name
}

output "vnet_id" {
  description = "VNet ID"
  value       = module.networking.vnet_id
}

output "instance_ids" {
  description = "VM instance IDs"
  value       = module.compute.instance_ids
}

output "instance_public_ips" {
  description = "Public IP addresses of instances"
  value       = module.compute.public_ips
}

output "storage_account_name" {
  description = "Storage account name"
  value       = module.storage.bucket_name
}
