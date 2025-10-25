# Networking Module
# This module creates a VPC/VNet with subnets and basic networking configuration
# Supports AWS, Azure, and GCP

terraform {
  required_version = ">= 1.0"
}

# AWS VPC
resource "aws_vpc" "main" {
  count = var.cloud_provider == "aws" ? 1 : 0

  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-vpc"
    }
  )
}

resource "aws_subnet" "public" {
  count = var.cloud_provider == "aws" ? length(var.public_subnet_cidrs) : 0

  vpc_id                  = aws_vpc.main[0].id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-public-subnet-${count.index + 1}"
      Type = "public"
    }
  )
}

resource "aws_subnet" "private" {
  count = var.cloud_provider == "aws" ? length(var.private_subnet_cidrs) : 0

  vpc_id            = aws_vpc.main[0].id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-private-subnet-${count.index + 1}"
      Type = "private"
    }
  )
}

resource "aws_internet_gateway" "main" {
  count = var.cloud_provider == "aws" && var.create_internet_gateway ? 1 : 0

  vpc_id = aws_vpc.main[0].id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-igw"
    }
  )
}

resource "aws_route_table" "public" {
  count = var.cloud_provider == "aws" ? 1 : 0

  vpc_id = aws_vpc.main[0].id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-public-rt"
    }
  )
}

resource "aws_route" "public_internet" {
  count = var.cloud_provider == "aws" && var.create_internet_gateway ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main[0].id
}

resource "aws_route_table_association" "public" {
  count = var.cloud_provider == "aws" ? length(var.public_subnet_cidrs) : 0

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

# Azure VNet
resource "azurerm_virtual_network" "main" {
  count = var.cloud_provider == "azure" ? 1 : 0

  name                = "${var.project_name}-vnet"
  address_space       = [var.vpc_cidr]
  location            = var.azure_location
  resource_group_name = var.azure_resource_group_name

  tags = var.tags
}

resource "azurerm_subnet" "public" {
  count = var.cloud_provider == "azure" ? length(var.public_subnet_cidrs) : 0

  name                 = "${var.project_name}-public-subnet-${count.index + 1}"
  resource_group_name  = var.azure_resource_group_name
  virtual_network_name = azurerm_virtual_network.main[0].name
  address_prefixes     = [var.public_subnet_cidrs[count.index]]
}

resource "azurerm_subnet" "private" {
  count = var.cloud_provider == "azure" ? length(var.private_subnet_cidrs) : 0

  name                 = "${var.project_name}-private-subnet-${count.index + 1}"
  resource_group_name  = var.azure_resource_group_name
  virtual_network_name = azurerm_virtual_network.main[0].name
  address_prefixes     = [var.private_subnet_cidrs[count.index]]
}

# GCP VPC
resource "google_compute_network" "main" {
  count = var.cloud_provider == "gcp" ? 1 : 0

  name                    = "${var.project_name}-vpc"
  auto_create_subnetworks = false
  project                 = var.gcp_project_id
}

resource "google_compute_subnetwork" "public" {
  count = var.cloud_provider == "gcp" ? length(var.public_subnet_cidrs) : 0

  name          = "${var.project_name}-public-subnet-${count.index + 1}"
  ip_cidr_range = var.public_subnet_cidrs[count.index]
  region        = var.gcp_region
  network       = google_compute_network.main[0].id
  project       = var.gcp_project_id
}

resource "google_compute_subnetwork" "private" {
  count = var.cloud_provider == "gcp" ? length(var.private_subnet_cidrs) : 0

  name          = "${var.project_name}-private-subnet-${count.index + 1}"
  ip_cidr_range = var.private_subnet_cidrs[count.index]
  region        = var.gcp_region
  network       = google_compute_network.main[0].id
  project       = var.gcp_project_id
}
