// Blueprint data for the gallery
export const blueprintDetails = {
  'vpc-subnets': {
    title: 'VPC + Subnets (Terraform)',
    description: 'Complete AWS VPC setup with public/private subnets',
    content: `
## Overview

This blueprint creates a production-ready AWS VPC with:
- Public and private subnets across multiple availability zones
- NAT gateways for private subnet internet access
- Route tables with proper routing configuration
- Network ACLs for security

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform 1.0 or later
- Basic understanding of AWS networking

## Usage

\`\`\`hcl
module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr = "10.0.0.0/16"
  azs      = ["us-east-1a", "us-east-1b", "us-east-1c"]
  
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  
  enable_nat_gateway = true
  single_nat_gateway = false
  
  tags = {
    Environment = "production"
    Project     = "the-terraformer"
  }
}
\`\`\`

## Resources Created

- 1 VPC
- 6 Subnets (3 public, 3 private)
- 3 NAT Gateways
- Internet Gateway
- Route Tables
- Security Groups

## Cost Estimate

Approximate monthly cost: $100-150 (primarily NAT Gateway charges)
    `,
  },
  'eks-cluster': {
    title: 'EKS/Kubernetes Cluster (Terraform)',
    description: 'Production-ready Amazon EKS cluster',
    content: `
## Overview

Deploy a secure, production-ready EKS cluster with managed node groups.

## Features

- Managed Kubernetes control plane
- Auto-scaling node groups
- RBAC configuration
- CloudWatch integration
- VPC CNI for networking

## Coming Soon

Full implementation and documentation in progress.
    `,
  },
};
