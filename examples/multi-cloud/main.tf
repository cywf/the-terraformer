# Multi-Cloud Example
# Deploy infrastructure across AWS, Azure, and GCP simultaneously

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Provider Configurations
provider "aws" {
  region = var.aws_region
}

provider "azurerm" {
  features {}
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# AWS Resources
module "aws_networking" {
  source = "../../modules/networking"

  cloud_provider       = "aws"
  project_name         = "${var.project_name}-aws"
  vpc_cidr            = var.aws_vpc_cidr
  public_subnet_cidrs = var.aws_public_subnet_cidrs
  private_subnet_cidrs = var.aws_private_subnet_cidrs
  availability_zones   = var.aws_availability_zones

  tags = merge(local.common_tags, { Provider = "AWS" })
}

module "aws_storage" {
  source = "../../modules/storage"

  cloud_provider = "aws"
  project_name   = "${var.project_name}-aws"
  bucket_suffix  = "data-${random_string.suffix.result}"

  tags = merge(local.common_tags, { Provider = "AWS" })
}

# Azure Resources
resource "azurerm_resource_group" "main" {
  name     = "${var.project_name}-azure-rg"
  location = var.azure_location

  tags = merge(local.common_tags, { Provider = "Azure" })
}

module "azure_networking" {
  source = "../../modules/networking"

  cloud_provider            = "azure"
  project_name              = "${var.project_name}-azure"
  vpc_cidr                  = var.azure_vnet_cidr
  public_subnet_cidrs       = var.azure_public_subnet_cidrs
  private_subnet_cidrs      = var.azure_private_subnet_cidrs
  azure_location            = var.azure_location
  azure_resource_group_name = azurerm_resource_group.main.name

  tags = merge(local.common_tags, { Provider = "Azure" })
}

module "azure_storage" {
  source = "../../modules/storage"

  cloud_provider            = "azure"
  project_name              = "${var.project_name}-azure"
  bucket_suffix             = random_string.suffix.result
  azure_location            = var.azure_location
  azure_resource_group_name = azurerm_resource_group.main.name

  tags = merge(local.common_tags, { Provider = "Azure" })
}

# GCP Resources
module "gcp_networking" {
  source = "../../modules/networking"

  cloud_provider       = "gcp"
  project_name         = "${var.project_name}-gcp"
  vpc_cidr            = var.gcp_vpc_cidr
  public_subnet_cidrs = var.gcp_public_subnet_cidrs
  private_subnet_cidrs = var.gcp_private_subnet_cidrs
  gcp_project_id       = var.gcp_project_id
  gcp_region           = var.gcp_region

  tags = merge(local.common_tags, { provider = "gcp" })
}

module "gcp_storage" {
  source = "../../modules/storage"

  cloud_provider = "gcp"
  project_name   = "${var.project_name}-gcp"
  bucket_suffix  = "data-${random_string.suffix.result}"
  gcp_project_id = var.gcp_project_id
  gcp_region     = var.gcp_region

  tags = merge(local.common_tags, { provider = "gcp" })
}

# Shared Resources
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Example     = "multi-cloud"
  }
}
