output "network_id" {
  description = "VPC network ID"
  value       = module.networking.network_id
}

output "instance_ids" {
  description = "Compute instance IDs"
  value       = module.compute.instance_ids
}

output "instance_public_ips" {
  description = "Public IP addresses of instances"
  value       = module.compute.public_ips
}

output "storage_bucket_name" {
  description = "Storage bucket name"
  value       = module.storage.bucket_name
}
