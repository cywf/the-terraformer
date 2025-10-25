variable "cloud_provider" {
  description = "Cloud provider to use (aws, azure, gcp)"
  type        = string
  validation {
    condition     = contains(["aws", "azure", "gcp"], var.cloud_provider)
    error_message = "Cloud provider must be one of: aws, azure, gcp"
  }
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the cluster"
  type        = list(string)
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}

variable "node_count" {
  description = "Number of nodes in the cluster"
  type        = number
  default     = 3
}

variable "node_instance_type" {
  description = "Instance type for cluster nodes"
  type        = string
  default     = "t3.medium" # AWS default
}

variable "enable_autoscaling" {
  description = "Enable cluster autoscaling"
  type        = bool
  default     = false
}

variable "enable_public_access" {
  description = "Enable public access to cluster API"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# AWS specific
variable "aws_cluster_role_arn" {
  description = "ARN of IAM role for EKS cluster"
  type        = string
  default     = ""
}

variable "aws_node_role_arn" {
  description = "ARN of IAM role for EKS node group"
  type        = string
  default     = ""
}

# Azure specific
variable "azure_location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "azure_resource_group_name" {
  description = "Azure resource group name"
  type        = string
  default     = ""
}

# GCP specific
variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
  default     = ""
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "gcp_network_name" {
  description = "GCP VPC network name"
  type        = string
  default     = ""
}

variable "gcp_pod_cidr" {
  description = "CIDR range for GKE pods"
  type        = string
  default     = "10.1.0.0/16"
}

variable "gcp_service_cidr" {
  description = "CIDR range for GKE services"
  type        = string
  default     = "10.2.0.0/16"
}

variable "gcp_master_cidr" {
  description = "CIDR range for GKE master"
  type        = string
  default     = "172.16.0.0/28"
}
