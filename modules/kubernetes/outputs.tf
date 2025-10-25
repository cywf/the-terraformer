output "cluster_id" {
  description = "ID of the Kubernetes cluster"
  value = var.cloud_provider == "aws" ? aws_eks_cluster.main[0].id : (
    var.cloud_provider == "azure" ? azurerm_kubernetes_cluster.main[0].id : (
      var.cloud_provider == "gcp" ? google_container_cluster.main[0].id : ""
    )
  )
}

output "cluster_name" {
  description = "Name of the Kubernetes cluster"
  value = var.cloud_provider == "aws" ? aws_eks_cluster.main[0].name : (
    var.cloud_provider == "azure" ? azurerm_kubernetes_cluster.main[0].name : (
      var.cloud_provider == "gcp" ? google_container_cluster.main[0].name : ""
    )
  )
}

output "cluster_endpoint" {
  description = "Endpoint for the Kubernetes cluster"
  value = var.cloud_provider == "aws" ? aws_eks_cluster.main[0].endpoint : (
    var.cloud_provider == "azure" ? azurerm_kubernetes_cluster.main[0].kube_config[0].host : (
      var.cloud_provider == "gcp" ? google_container_cluster.main[0].endpoint : ""
    )
  )
}

output "cluster_ca_certificate" {
  description = "CA certificate for the Kubernetes cluster"
  value = var.cloud_provider == "aws" ? aws_eks_cluster.main[0].certificate_authority[0].data : (
    var.cloud_provider == "azure" ? azurerm_kubernetes_cluster.main[0].kube_config[0].cluster_ca_certificate : (
      var.cloud_provider == "gcp" ? google_container_cluster.main[0].master_auth[0].cluster_ca_certificate : ""
    )
  )
  sensitive = true
}

output "kubeconfig_command" {
  description = "Command to configure kubectl"
  value = var.cloud_provider == "aws" ? "aws eks update-kubeconfig --name ${aws_eks_cluster.main[0].name} --region ${split(":", aws_eks_cluster.main[0].arn)[3]}" : (
    var.cloud_provider == "azure" ? "az aks get-credentials --resource-group ${var.azure_resource_group_name} --name ${azurerm_kubernetes_cluster.main[0].name}" : (
      var.cloud_provider == "gcp" ? "gcloud container clusters get-credentials ${google_container_cluster.main[0].name} --region ${var.gcp_region} --project ${var.gcp_project_id}" : ""
    )
  )
}
