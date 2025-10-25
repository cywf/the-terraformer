# Multi-Cloud Example

This example demonstrates deploying infrastructure across AWS, Azure, and GCP simultaneously using The Terraformer modules.

## Overview

This configuration creates:

**AWS:**
- VPC with public and private subnets
- S3 bucket with encryption

**Azure:**
- Resource Group
- VNet with public and private subnets
- Storage Account with container

**GCP:**
- VPC with public and private subnets
- Cloud Storage bucket

## Prerequisites

1. **Cloud Provider Accounts**
   - AWS account with credentials configured
   - Azure subscription with credentials configured
   - GCP project with credentials configured

2. **CLI Tools**
   ```bash
   # AWS CLI
   aws configure
   
   # Azure CLI
   az login
   
   # GCP CLI
   gcloud auth application-default login
   ```

3. **Terraform >= 1.0**

## Usage

### 1. Configure Variables

Copy the example variables:
```bash
cp example.tfvars terraform.tfvars
```

Edit `terraform.tfvars`:
```hcl
project_name = "my-multi-cloud-app"
environment  = "dev"

# AWS
aws_region = "us-east-1"

# Azure
azure_location = "eastus"

# GCP
gcp_project_id = "my-gcp-project-id"
gcp_region     = "us-central1"
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Review the Plan

```bash
terraform plan
```

This will show resources to be created across all three cloud providers.

### 4. Deploy

```bash
terraform apply
```

### 5. View Outputs

```bash
terraform output deployment_summary
```

Output will show:
```json
{
  "aws": {
    "bucket": "my-project-aws-data-abc123",
    "region": "us-east-1",
    "vpc_id": "vpc-xxxxx"
  },
  "azure": {
    "location": "eastus",
    "storage": "myprojectazureabc123",
    "vnet_id": "/subscriptions/.../vnet-xxxxx"
  },
  "gcp": {
    "bucket": "my-project-gcp-data-abc123",
    "network_id": "projects/.../networks/my-project-gcp-vpc",
    "region": "us-central1"
  }
}
```

### 6. Clean Up

```bash
terraform destroy
```

## Use Cases

### 1. Disaster Recovery

Deploy resources across multiple clouds for redundancy:
- Primary: AWS
- Secondary: Azure
- Tertiary: GCP

### 2. Multi-Region Applications

Serve users from the nearest cloud region:
- North America: AWS us-east-1
- Europe: Azure westeurope
- Asia: GCP asia-southeast1

### 3. Vendor Lock-in Avoidance

Maintain flexibility by keeping infrastructure portable across providers.

### 4. Cost Optimization

Leverage best pricing from each provider:
- Storage: Use provider with best rates
- Compute: Choose most cost-effective instances
- Network: Minimize cross-provider traffic costs

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   Multi-Cloud Setup                      │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │     AWS      │  │    Azure     │  │     GCP      │ │
│  ├──────────────┤  ├──────────────┤  ├──────────────┤ │
│  │ VPC          │  │ VNet         │  │ VPC          │ │
│  │ - Public     │  │ - Public     │  │ - Public     │ │
│  │ - Private    │  │ - Private    │  │ - Private    │ │
│  │              │  │              │  │              │ │
│  │ S3 Bucket    │  │ Blob Storage │  │ GCS Bucket   │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

## Networking Considerations

### CIDR Planning

This example uses non-overlapping CIDRs:
- AWS: 10.0.0.0/16
- Azure: 10.1.0.0/16
- GCP: 10.2.0.0/16

This allows for potential VPN or peering connections between clouds.

### Inter-Cloud Connectivity

To connect networks across clouds, you can:

1. **VPN Connections**
   - AWS VPN Gateway ↔ Azure VPN Gateway
   - GCP Cloud VPN ↔ AWS/Azure

2. **Direct Connect / ExpressRoute / Interconnect**
   - Dedicated high-bandwidth connections

3. **Third-Party Solutions**
   - Aviatrix
   - HashiCorp Consul Connect

## Cost Estimation

Approximate monthly costs (minimal setup):

| Provider | Resources | Estimated Cost |
|----------|-----------|----------------|
| AWS | VPC (free), S3 bucket | ~$0.50 |
| Azure | VNet (free), Storage Account | ~$0.50 |
| GCP | VPC (free), GCS bucket | ~$0.50 |
| **Total** | | **~$1.50/month** |

*Note: Costs will increase with compute resources and data transfer.*

## Best Practices

1. **Unified Tagging**: Use consistent tags across all providers
2. **Separate State Files**: Consider separate state files per provider
3. **Provider Aliases**: Use aliases for multiple regions per provider
4. **Cost Monitoring**: Set up billing alerts for each provider
5. **Security**: Apply security best practices for each platform

## Extending the Example

### Add Compute Resources

```hcl
module "aws_compute" {
  source = "../../modules/compute"
  
  cloud_provider = "aws"
  instance_count = 2
  subnet_ids     = module.aws_networking.public_subnet_ids
}
```

### Add Kubernetes Clusters

```hcl
module "gcp_kubernetes" {
  source = "../../modules/kubernetes"
  
  cloud_provider = "gcp"
  node_count     = 3
  subnet_ids     = module.gcp_networking.private_subnet_ids
}
```

## Troubleshooting

### Authentication Issues

```bash
# Verify AWS credentials
aws sts get-caller-identity

# Verify Azure credentials
az account show

# Verify GCP credentials
gcloud auth list
```

### Provider Version Conflicts

If you encounter version conflicts:
```bash
rm -rf .terraform .terraform.lock.hcl
terraform init -upgrade
```

## Additional Resources

- [Multi-Cloud Deployment Guide](../../docs/multi-cloud.md)
- [Security Best Practices](../../docs/security.md)
- [Cost Optimization Strategies](../../docs/cost-optimization.md)

---

**Note:** Multi-cloud deployments increase complexity. Start simple and expand as needed.
