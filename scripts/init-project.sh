#!/bin/bash

# The Terraformer - Project Initialization Script
# This script creates a new Terraform project using The Terraformer modules

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to display usage
usage() {
    cat << EOF
Usage: $0 <project-name> <cloud-provider> [options]

Arguments:
    project-name     Name of your project (required)
    cloud-provider   Cloud provider: aws, azure, gcp, or multi (required)

Options:
    -h, --help       Show this help message
    -d, --dir DIR    Custom directory (default: ./projects/<project-name>)
    -e, --env ENV    Environment name (default: dev)

Examples:
    $0 my-app aws
    $0 my-app azure --env production
    $0 my-app multi --dir ./custom-path

EOF
    exit 1
}

# Check if required arguments are provided
if [ $# -lt 2 ]; then
    print_error "Missing required arguments"
    usage
fi

PROJECT_NAME=$1
CLOUD_PROVIDER=$2
ENVIRONMENT="dev"
PROJECT_DIR="./projects/${PROJECT_NAME}"

# Parse optional arguments
shift 2
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -d|--dir)
            PROJECT_DIR="$2"
            shift 2
            ;;
        -e|--env)
            ENVIRONMENT="$2"
            shift 2
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            ;;
    esac
done

# Validate cloud provider
case $CLOUD_PROVIDER in
    aws|azure|gcp|multi)
        ;;
    *)
        print_error "Invalid cloud provider: $CLOUD_PROVIDER"
        print_error "Must be one of: aws, azure, gcp, multi"
        exit 1
        ;;
esac

# Check if directory already exists
if [ -d "$PROJECT_DIR" ]; then
    print_error "Directory $PROJECT_DIR already exists"
    exit 1
fi

print_info "Initializing project: $PROJECT_NAME"
print_info "Cloud provider: $CLOUD_PROVIDER"
print_info "Environment: $ENVIRONMENT"
print_info "Project directory: $PROJECT_DIR"

# Create project directory structure
print_info "Creating project structure..."
mkdir -p "$PROJECT_DIR"
mkdir -p "$PROJECT_DIR/environments/${ENVIRONMENT}"
mkdir -p "$PROJECT_DIR/modules"

# Create main.tf based on cloud provider
print_info "Creating Terraform configuration..."

cat > "$PROJECT_DIR/environments/${ENVIRONMENT}/main.tf" << EOF
# ${PROJECT_NAME} - ${CLOUD_PROVIDER} Infrastructure
# Environment: ${ENVIRONMENT}

terraform {
  required_version = ">= 1.0"
  
  required_providers {
EOF

# Add provider configurations based on cloud provider
case $CLOUD_PROVIDER in
    aws)
        cat >> "$PROJECT_DIR/environments/${ENVIRONMENT}/main.tf" << EOF
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
EOF
        ;;
    azure)
        cat >> "$PROJECT_DIR/environments/${ENVIRONMENT}/main.tf" << EOF
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
EOF
        ;;
    gcp)
        cat >> "$PROJECT_DIR/environments/${ENVIRONMENT}/main.tf" << EOF
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
EOF
        ;;
    multi)
        cat >> "$PROJECT_DIR/environments/${ENVIRONMENT}/main.tf" << EOF
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
EOF
        ;;
esac

cat >> "$PROJECT_DIR/environments/${ENVIRONMENT}/main.tf" << 'EOF'
  }
  
  # Configure remote backend (uncomment and configure for production)
  # backend "s3" {
  #   bucket = "my-terraform-state"
  #   key    = "project-name/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

# Provider configuration
# TODO: Configure your provider(s)

# Import modules from The Terraformer
# Uncomment and configure the modules you need

# module "networking" {
#   source = "../../../modules/networking"
#   
#   cloud_provider = var.cloud_provider
#   project_name   = var.project_name
#   vpc_cidr       = var.vpc_cidr
#   tags           = local.common_tags
# }

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
EOF

# Create variables.tf
cat > "$PROJECT_DIR/environments/${ENVIRONMENT}/variables.tf" << EOF
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "${PROJECT_NAME}"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "${ENVIRONMENT}"
}

variable "cloud_provider" {
  description = "Cloud provider (aws, azure, gcp)"
  type        = string
  default     = "${CLOUD_PROVIDER}"
}

# Add your custom variables here
EOF

# Create outputs.tf
cat > "$PROJECT_DIR/environments/${ENVIRONMENT}/outputs.tf" << 'EOF'
# Define your outputs here

# output "vpc_id" {
#   description = "VPC ID"
#   value       = module.networking.vpc_id
# }
EOF

# Create example.tfvars
cat > "$PROJECT_DIR/environments/${ENVIRONMENT}/example.tfvars" << EOF
project_name   = "${PROJECT_NAME}"
environment    = "${ENVIRONMENT}"
cloud_provider = "${CLOUD_PROVIDER}"

# Add your variable values here
EOF

# Create README.md
cat > "$PROJECT_DIR/README.md" << EOF
# ${PROJECT_NAME}

Infrastructure as Code for ${PROJECT_NAME} using Terraform.

## Overview

- **Cloud Provider**: ${CLOUD_PROVIDER}
- **Environment**: ${ENVIRONMENT}
- **Managed By**: The Terraformer

## Prerequisites

- Terraform >= 1.0
- Cloud provider CLI and credentials configured

## Getting Started

1. Navigate to the environment directory:
   \`\`\`bash
   cd environments/${ENVIRONMENT}
   \`\`\`

2. Copy and configure variables:
   \`\`\`bash
   cp example.tfvars terraform.tfvars
   # Edit terraform.tfvars with your values
   \`\`\`

3. Initialize Terraform:
   \`\`\`bash
   terraform init
   \`\`\`

4. Plan the deployment:
   \`\`\`bash
   terraform plan
   \`\`\`

5. Apply the configuration:
   \`\`\`bash
   terraform apply
   \`\`\`

## Project Structure

\`\`\`
${PROJECT_NAME}/
├── environments/
│   └── ${ENVIRONMENT}/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── example.tfvars
├── modules/          # Custom modules (optional)
└── README.md
\`\`\`

## Next Steps

1. Configure your provider credentials
2. Uncomment and configure the modules you need in main.tf
3. Add your infrastructure resources
4. Update variables and outputs as needed

## Documentation

- [The Terraformer Documentation](https://github.com/cywf/the-terraformer)
- [Terraform Documentation](https://www.terraform.io/docs)

EOF

# Create .gitignore if it doesn't exist
if [ ! -f "$PROJECT_DIR/.gitignore" ]; then
    cp "$(dirname "$0")/../.gitignore" "$PROJECT_DIR/.gitignore" 2>/dev/null || cat > "$PROJECT_DIR/.gitignore" << 'EOF'
# Terraform
*.tfstate
*.tfstate.*
*.tfvars
!example.tfvars
.terraform/
.terraform.lock.hcl

# IDE
.vscode/
.idea/
*.swp

# OS
.DS_Store
EOF
fi

print_info "Project initialized successfully!"
echo ""
print_info "Next steps:"
echo "  1. cd $PROJECT_DIR/environments/${ENVIRONMENT}"
echo "  2. cp example.tfvars terraform.tfvars"
echo "  3. Edit terraform.tfvars with your configuration"
echo "  4. terraform init"
echo "  5. terraform plan"
echo ""
print_info "For more information, see $PROJECT_DIR/README.md"

exit 0
