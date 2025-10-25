# GCP Simple Example

terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# Networking
module "networking" {
  source = "../../modules/networking"

  cloud_provider       = "gcp"
  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  gcp_project_id       = var.gcp_project_id
  gcp_region           = var.gcp_region

  tags = local.common_tags
}

# Firewall Rules
resource "google_compute_firewall" "ssh" {
  name    = "${var.project_name}-allow-ssh"
  network = module.networking.network_name
  project = var.gcp_project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.allowed_ssh_cidrs
  target_tags   = [var.project_name]
}

resource "google_compute_firewall" "http" {
  name    = "${var.project_name}-allow-http"
  network = module.networking.network_name
  project = var.gcp_project_id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = [var.project_name]
}

# Compute
module "compute" {
  source = "../../modules/compute"

  cloud_provider     = "gcp"
  project_name       = var.project_name
  instance_count     = var.instance_count
  instance_type      = var.instance_type
  subnet_ids         = module.networking.public_subnet_ids
  gcp_project_id     = var.gcp_project_id
  gcp_zone           = var.gcp_zone
  gcp_image          = var.gcp_image
  admin_username     = var.admin_username
  ssh_public_key     = var.ssh_public_key
  assign_public_ip   = true
  gcp_network_tags   = [var.project_name]

  tags = local.common_tags
}

# Storage
module "storage" {
  source = "../../modules/storage"

  cloud_provider = "gcp"
  project_name   = var.project_name
  bucket_suffix  = "data-${random_string.suffix.result}"
  gcp_project_id = var.gcp_project_id
  gcp_region     = var.gcp_region

  tags = local.common_tags
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

locals {
  common_tags = {
    project     = var.project_name
    environment = var.environment
    managed_by  = "terraform"
    example     = "gcp-simple"
  }
}
