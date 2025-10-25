variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "multi-cloud-example"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

# AWS Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_vpc_cidr" {
  description = "AWS VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "aws_public_subnet_cidrs" {
  description = "AWS public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "aws_private_subnet_cidrs" {
  description = "AWS private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "aws_availability_zones" {
  description = "AWS availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# Azure Variables
variable "azure_location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "azure_vnet_cidr" {
  description = "Azure VNet CIDR"
  type        = string
  default     = "10.1.0.0/16"
}

variable "azure_public_subnet_cidrs" {
  description = "Azure public subnet CIDRs"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "azure_private_subnet_cidrs" {
  description = "Azure private subnet CIDRs"
  type        = list(string)
  default     = ["10.1.10.0/24", "10.1.11.0/24"]
}

# GCP Variables
variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "gcp_vpc_cidr" {
  description = "GCP VPC CIDR"
  type        = string
  default     = "10.2.0.0/16"
}

variable "gcp_public_subnet_cidrs" {
  description = "GCP public subnet CIDRs"
  type        = list(string)
  default     = ["10.2.1.0/24", "10.2.2.0/24"]
}

variable "gcp_private_subnet_cidrs" {
  description = "GCP private subnet CIDRs"
  type        = list(string)
  default     = ["10.2.10.0/24", "10.2.11.0/24"]
}
