# AWS Simple Example
# This example creates a basic infrastructure setup on AWS with:
# - VPC with public and private subnets
# - EC2 instances
# - S3 bucket for storage

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Networking
module "networking" {
  source = "../../modules/networking"

  cloud_provider       = "aws"
  project_name         = var.project_name
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones

  tags = local.common_tags
}

# Security Group for EC2 instances
resource "aws_security_group" "instances" {
  name        = "${var.project_name}-instances-sg"
  description = "Security group for EC2 instances"
  vpc_id      = module.networking.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
    description = "SSH access"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = local.common_tags
}

# Compute
module "compute" {
  source = "../../modules/compute"

  cloud_provider     = "aws"
  project_name       = var.project_name
  instance_count     = var.instance_count
  instance_type      = var.instance_type
  aws_ami_id         = var.aws_ami_id
  subnet_ids         = module.networking.public_subnet_ids
  security_group_ids = [aws_security_group.instances.id]
  ssh_key_name       = var.ssh_key_name
  assign_public_ip   = true

  tags = local.common_tags
}

# Storage
module "storage" {
  source = "../../modules/storage"

  cloud_provider    = "aws"
  project_name      = var.project_name
  bucket_suffix     = "data-${random_string.suffix.result}"
  enable_versioning = true

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
    Example     = "aws-simple"
  }
}
