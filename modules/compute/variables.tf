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

variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1
}

variable "instance_type" {
  description = "Instance type/size"
  type        = string
  default     = "t3.micro" # AWS default, override for other providers
}

variable "subnet_ids" {
  description = "List of subnet IDs for instance placement"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs (AWS)"
  type        = list(string)
  default     = []
}

variable "disk_size_gb" {
  description = "Size of the root disk in GB"
  type        = number
  default     = 30
}

variable "assign_public_ip" {
  description = "Assign public IP to instances"
  type        = bool
  default     = false
}

variable "user_data_script" {
  description = "User data script to run on instance launch"
  type        = string
  default     = ""
}

variable "ssh_key_name" {
  description = "SSH key pair name (AWS)"
  type        = string
  default     = ""
}

variable "ssh_public_key" {
  description = "SSH public key content (Azure, GCP)"
  type        = string
  default     = ""
}

variable "admin_username" {
  description = "Admin username for the instance"
  type        = string
  default     = "adminuser"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# AWS specific
variable "aws_ami_id" {
  description = "AMI ID for AWS EC2 instances"
  type        = string
  default     = "" # Must be provided if using AWS
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

variable "gcp_zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "gcp_image" {
  description = "GCP image"
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2204-lts"
}

variable "gcp_network_tags" {
  description = "Network tags for GCP instances"
  type        = list(string)
  default     = []
}
