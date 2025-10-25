# AWS Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = var.cloud_provider == "aws" ? aws_vpc.main[0].id : null
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = var.vpc_cidr
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value = var.cloud_provider == "aws" ? aws_subnet.public[*].id : (
    var.cloud_provider == "azure" ? azurerm_subnet.public[*].id : (
      var.cloud_provider == "gcp" ? google_compute_subnetwork.public[*].id : []
    )
  )
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value = var.cloud_provider == "aws" ? aws_subnet.private[*].id : (
    var.cloud_provider == "azure" ? azurerm_subnet.private[*].id : (
      var.cloud_provider == "gcp" ? google_compute_subnetwork.private[*].id : []
    )
  )
}

output "internet_gateway_id" {
  description = "ID of the internet gateway (AWS only)"
  value       = var.cloud_provider == "aws" && var.create_internet_gateway ? aws_internet_gateway.main[0].id : null
}

# Azure Outputs
output "vnet_id" {
  description = "ID of the VNet (Azure only)"
  value       = var.cloud_provider == "azure" ? azurerm_virtual_network.main[0].id : null
}

# GCP Outputs
output "network_id" {
  description = "ID of the VPC network (GCP only)"
  value       = var.cloud_provider == "gcp" ? google_compute_network.main[0].id : null
}

output "network_name" {
  description = "Name of the network"
  value = var.cloud_provider == "aws" ? aws_vpc.main[0].id : (
    var.cloud_provider == "azure" ? azurerm_virtual_network.main[0].name : (
      var.cloud_provider == "gcp" ? google_compute_network.main[0].name : ""
    )
  )
}
