# AWS Outputs
output "instance_ids" {
  description = "IDs of the instances"
  value = var.cloud_provider == "aws" ? aws_instance.main[*].id : (
    var.cloud_provider == "azure" ? azurerm_linux_virtual_machine.main[*].id : (
      var.cloud_provider == "gcp" ? google_compute_instance.main[*].id : []
    )
  )
}

output "private_ips" {
  description = "Private IP addresses of instances"
  value = var.cloud_provider == "aws" ? aws_instance.main[*].private_ip : (
    var.cloud_provider == "azure" ? azurerm_network_interface.main[*].private_ip_address : (
      var.cloud_provider == "gcp" ? google_compute_instance.main[*].network_interface[0].network_ip : []
    )
  )
}

output "public_ips" {
  description = "Public IP addresses of instances (if assigned)"
  value = var.cloud_provider == "aws" ? aws_instance.main[*].public_ip : (
    var.cloud_provider == "azure" && var.assign_public_ip ? azurerm_public_ip.main[*].ip_address : (
      var.cloud_provider == "gcp" && var.assign_public_ip ? [
        for instance in google_compute_instance.main :
        length(instance.network_interface[0].access_config) > 0 ? instance.network_interface[0].access_config[0].nat_ip : ""
      ] : []
    )
  )
}

output "instance_names" {
  description = "Names of the instances"
  value = var.cloud_provider == "aws" ? aws_instance.main[*].tags["Name"] : (
    var.cloud_provider == "azure" ? azurerm_linux_virtual_machine.main[*].name : (
      var.cloud_provider == "gcp" ? google_compute_instance.main[*].name : []
    )
  )
}
