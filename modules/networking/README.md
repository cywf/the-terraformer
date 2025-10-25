# Networking Module

This module creates networking infrastructure across AWS, Azure, and GCP.

## Features

- **Multi-cloud support**: Works with AWS (VPC), Azure (VNet), and GCP (VPC)
- **Public and private subnets**: Creates separate subnet tiers
- **Internet connectivity**: Optional internet gateway for public access
- **Configurable CIDR blocks**: Flexible IP address ranges

## Usage

### AWS Example

```hcl
module "networking" {
  source = "../../modules/networking"

  cloud_provider       = "aws"
  project_name         = "my-project"
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
  availability_zones   = ["us-east-1a", "us-east-1b"]
  
  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### Azure Example

```hcl
module "networking" {
  source = "../../modules/networking"

  cloud_provider            = "azure"
  project_name              = "my-project"
  vpc_cidr                  = "10.0.0.0/16"
  public_subnet_cidrs       = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs      = ["10.0.10.0/24", "10.0.11.0/24"]
  azure_location            = "eastus"
  azure_resource_group_name = "my-resource-group"
  
  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### GCP Example

```hcl
module "networking" {
  source = "../../modules/networking"

  cloud_provider       = "gcp"
  project_name         = "my-project"
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
  gcp_project_id       = "my-gcp-project"
  gcp_region           = "us-central1"
  
  tags = {
    environment = "production"
    managed_by  = "terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cloud_provider | Cloud provider (aws, azure, gcp) | string | n/a | yes |
| project_name | Project name for resource naming | string | n/a | yes |
| vpc_cidr | CIDR block for VPC/VNet | string | "10.0.0.0/16" | no |
| public_subnet_cidrs | CIDR blocks for public subnets | list(string) | ["10.0.1.0/24", "10.0.2.0/24"] | no |
| private_subnet_cidrs | CIDR blocks for private subnets | list(string) | ["10.0.10.0/24", "10.0.11.0/24"] | no |
| availability_zones | Availability zones (AWS) | list(string) | [] | no |
| create_internet_gateway | Create internet gateway (AWS) | bool | true | no |
| tags | Resource tags | map(string) | {} | no |
| azure_location | Azure region | string | "eastus" | no |
| azure_resource_group_name | Azure resource group | string | "" | no |
| gcp_project_id | GCP project ID | string | "" | no |
| gcp_region | GCP region | string | "us-central1" | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | VPC ID (AWS) |
| vnet_id | VNet ID (Azure) |
| network_id | Network ID (GCP) |
| network_name | Network name |
| public_subnet_ids | Public subnet IDs |
| private_subnet_ids | Private subnet IDs |
| internet_gateway_id | Internet gateway ID (AWS) |
