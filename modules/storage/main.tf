# Storage Module
# This module creates object storage across AWS, Azure, and GCP

terraform {
  required_version = ">= 1.0"
}

# AWS S3 Bucket
resource "aws_s3_bucket" "main" {
  count = var.cloud_provider == "aws" ? 1 : 0

  bucket = "${var.project_name}-${var.bucket_suffix}"

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-bucket"
    }
  )
}

resource "aws_s3_bucket_versioning" "main" {
  count = var.cloud_provider == "aws" && var.enable_versioning ? 1 : 0

  bucket = aws_s3_bucket.main[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  count = var.cloud_provider == "aws" ? 1 : 0

  bucket = aws_s3_bucket.main[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  count = var.cloud_provider == "aws" ? 1 : 0

  bucket = aws_s3_bucket.main[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Azure Storage Account and Container
resource "azurerm_storage_account" "main" {
  count = var.cloud_provider == "azure" ? 1 : 0

  name                     = replace("${var.project_name}${var.bucket_suffix}", "-", "")
  resource_group_name      = var.azure_resource_group_name
  location                 = var.azure_location
  account_tier             = "Standard"
  account_replication_type = var.azure_replication_type
  min_tls_version          = "TLS1_2"

  tags = var.tags
}

resource "azurerm_storage_container" "main" {
  count = var.cloud_provider == "azure" ? 1 : 0

  name                  = "${var.project_name}-container"
  storage_account_name  = azurerm_storage_account.main[0].name
  container_access_type = "private"
}

# GCP Storage Bucket
resource "google_storage_bucket" "main" {
  count = var.cloud_provider == "gcp" ? 1 : 0

  name          = "${var.project_name}-${var.bucket_suffix}"
  location      = var.gcp_region
  project       = var.gcp_project_id
  force_destroy = var.force_destroy

  uniform_bucket_level_access = true

  versioning {
    enabled = var.enable_versioning
  }

  encryption {
    default_kms_key_name = var.gcp_kms_key_name
  }

  labels = var.tags
}
