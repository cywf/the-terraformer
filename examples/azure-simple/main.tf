# Azure Simple Example

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${var.project_name}-rg"
  location = var.azure_location

  tags = local.common_tags
}

# Networking
module "networking" {
  source = "../../modules/networking"

  cloud_provider            = "azure"
  project_name              = var.project_name
  vpc_cidr                  = var.vnet_cidr
  public_subnet_cidrs       = var.public_subnet_cidrs
  private_subnet_cidrs      = var.private_subnet_cidrs
  azure_location            = var.azure_location
  azure_resource_group_name = azurerm_resource_group.main.name

  tags = local.common_tags
}

# Network Security Group
resource "azurerm_network_security_group" "main" {
  name                = "${var.project_name}-nsg"
  location            = var.azure_location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = var.allowed_ssh_cidrs
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.common_tags
}

# Compute
module "compute" {
  source = "../../modules/compute"

  cloud_provider            = "azure"
  project_name              = var.project_name
  instance_count            = var.instance_count
  instance_type             = var.instance_type
  subnet_ids                = module.networking.public_subnet_ids
  azure_location            = var.azure_location
  azure_resource_group_name = azurerm_resource_group.main.name
  admin_username            = var.admin_username
  ssh_public_key            = var.ssh_public_key
  assign_public_ip          = true

  tags = local.common_tags
}

# Storage
module "storage" {
  source = "../../modules/storage"

  cloud_provider            = "azure"
  project_name              = var.project_name
  bucket_suffix             = random_string.suffix.result
  azure_location            = var.azure_location
  azure_resource_group_name = azurerm_resource_group.main.name
  enable_versioning         = true

  tags = local.common_tags
}

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
    Example     = "azure-simple"
  }
}
