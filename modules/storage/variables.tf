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

variable "bucket_suffix" {
  description = "Suffix for bucket name to ensure uniqueness"
  type        = string
  default     = "data"
}

variable "enable_versioning" {
  description = "Enable versioning for the bucket"
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Allow bucket deletion even if not empty (use with caution)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
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

variable "azure_replication_type" {
  description = "Azure storage replication type"
  type        = string
  default     = "LRS"
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

variable "gcp_kms_key_name" {
  description = "GCP KMS key name for encryption"
  type        = string
  default     = null
}
