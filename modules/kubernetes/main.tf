# Kubernetes Module
# This module creates managed Kubernetes clusters (EKS, AKS, GKE)

terraform {
  required_version = ">= 1.0"
}

# AWS EKS Cluster
resource "aws_eks_cluster" "main" {
  count = var.cloud_provider == "aws" ? 1 : 0

  name     = "${var.project_name}-eks"
  role_arn = var.aws_cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = var.enable_public_access
  }

  tags = var.tags
}

resource "aws_eks_node_group" "main" {
  count = var.cloud_provider == "aws" ? 1 : 0

  cluster_name    = aws_eks_cluster.main[0].name
  node_group_name = "${var.project_name}-node-group"
  node_role_arn   = var.aws_node_role_arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = var.node_count
    max_size     = var.node_count + 2
    min_size     = 1
  }

  instance_types = [var.node_instance_type]

  tags = var.tags
}

# Azure AKS Cluster
resource "azurerm_kubernetes_cluster" "main" {
  count = var.cloud_provider == "azure" ? 1 : 0

  name                = "${var.project_name}-aks"
  location            = var.azure_location
  resource_group_name = var.azure_resource_group_name
  dns_prefix          = "${var.project_name}-aks"
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                = "default"
    node_count          = var.node_count
    vm_size             = var.node_instance_type
    vnet_subnet_id      = var.subnet_ids[0]
    enable_auto_scaling = var.enable_autoscaling
    min_count           = var.enable_autoscaling ? 1 : null
    max_count           = var.enable_autoscaling ? var.node_count + 2 : null
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "calico"
  }

  tags = var.tags
}

# GCP GKE Cluster
resource "google_container_cluster" "main" {
  count = var.cloud_provider == "gcp" ? 1 : 0

  name     = "${var.project_name}-gke"
  location = var.gcp_region
  project  = var.gcp_project_id

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.gcp_network_name
  subnetwork = var.subnet_ids[0]

  min_master_version = var.kubernetes_version

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = var.gcp_pod_cidr
    services_ipv4_cidr_block = var.gcp_service_cidr
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = !var.enable_public_access
    master_ipv4_cidr_block  = var.gcp_master_cidr
  }

  workload_identity_config {
    workload_pool = "${var.gcp_project_id}.svc.id.goog"
  }

  resource_labels = var.tags
}

resource "google_container_node_pool" "main" {
  count = var.cloud_provider == "gcp" ? 1 : 0

  name       = "${var.project_name}-node-pool"
  location   = var.gcp_region
  cluster    = google_container_cluster.main[0].name
  project    = var.gcp_project_id
  node_count = var.node_count

  autoscaling {
    min_node_count = var.enable_autoscaling ? 1 : var.node_count
    max_node_count = var.enable_autoscaling ? var.node_count + 2 : var.node_count
  }

  node_config {
    machine_type = var.node_instance_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = var.tags
  }
}
