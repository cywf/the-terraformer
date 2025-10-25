# AWS Outputs
output "aws_vpc_id" {
  description = "AWS VPC ID"
  value       = module.aws_networking.vpc_id
}

output "aws_storage_bucket" {
  description = "AWS S3 bucket name"
  value       = module.aws_storage.bucket_name
}

# Azure Outputs
output "azure_vnet_id" {
  description = "Azure VNet ID"
  value       = module.azure_networking.vnet_id
}

output "azure_storage_account" {
  description = "Azure storage account name"
  value       = module.azure_storage.bucket_name
}

# GCP Outputs
output "gcp_network_id" {
  description = "GCP VPC network ID"
  value       = module.gcp_networking.network_id
}

output "gcp_storage_bucket" {
  description = "GCP storage bucket name"
  value       = module.gcp_storage.bucket_name
}

# Summary Output
output "deployment_summary" {
  description = "Multi-cloud deployment summary"
  value = {
    aws = {
      region = var.aws_region
      vpc_id = module.aws_networking.vpc_id
      bucket = module.aws_storage.bucket_name
    }
    azure = {
      location = var.azure_location
      vnet_id  = module.azure_networking.vnet_id
      storage  = module.azure_storage.bucket_name
    }
    gcp = {
      region     = var.gcp_region
      network_id = module.gcp_networking.network_id
      bucket     = module.gcp_storage.bucket_name
    }
  }
}
