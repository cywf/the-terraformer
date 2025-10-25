# Getting Started with The Terraformer

This guide will help you get started with The Terraformer template repository for Infrastructure as Code.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Your First Deployment](#your-first-deployment)
- [Understanding the Structure](#understanding-the-structure)
- [Common Workflows](#common-workflows)
- [Next Steps](#next-steps)

## Prerequisites

Before you begin, ensure you have:

1. **Terraform installed** (>= 1.0)
   ```bash
   # macOS
   brew install terraform
   
   # Linux
   wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
   unzip terraform_1.6.0_linux_amd64.zip
   sudo mv terraform /usr/local/bin/
   
   # Verify installation
   terraform version
   ```

2. **Cloud provider CLI** for your target platform:
   
   **AWS CLI:**
   ```bash
   brew install awscli
   aws configure
   ```
   
   **Azure CLI:**
   ```bash
   brew install azure-cli
   az login
   ```
   
   **Google Cloud SDK:**
   ```bash
   brew install --cask google-cloud-sdk
   gcloud init
   gcloud auth application-default login
   ```

3. **Git** for version control
   ```bash
   git --version
   ```

## Installation

### Option 1: Use as GitHub Template

1. Click "Use this template" on GitHub
2. Create your new repository
3. Clone your repository:
   ```bash
   git clone https://github.com/your-username/your-repo-name.git
   cd your-repo-name
   ```

### Option 2: Clone Directly

```bash
git clone https://github.com/cywf/the-terraformer.git my-infrastructure
cd my-infrastructure
rm -rf .git  # Remove git history if you want a fresh start
git init     # Initialize new git repository
```

## Your First Deployment

Let's deploy a simple AWS infrastructure to get started.

### Step 1: Choose an Example

Navigate to the AWS simple example:
```bash
cd examples/aws-simple
```

### Step 2: Configure Variables

Copy the example variables file:
```bash
cp example.tfvars terraform.tfvars
```

Edit `terraform.tfvars` with your values:
```hcl
aws_region   = "us-east-1"
project_name = "my-first-project"
environment  = "dev"

# Get AMI ID for your region
aws_ami_id   = "ami-0c55b159cbfafe1f0"

# Your EC2 key pair name
ssh_key_name = "my-key-pair"

# Restrict SSH access (important for security!)
allowed_ssh_cidrs = ["YOUR_IP_ADDRESS/32"]
```

### Step 3: Initialize Terraform

Initialize the Terraform working directory:
```bash
terraform init
```

This will:
- Download required provider plugins
- Initialize the backend
- Prepare your workspace

### Step 4: Review the Plan

Generate and review an execution plan:
```bash
terraform plan
```

Review the output to understand what will be created:
- VPC and subnets
- Security groups
- EC2 instances
- S3 bucket

### Step 5: Apply the Configuration

Deploy your infrastructure:
```bash
terraform apply
```

Type `yes` when prompted to confirm.

### Step 6: Verify Deployment

Once complete, Terraform will output important values:
```
Outputs:

vpc_id = "vpc-xxxxx"
instance_ids = ["i-xxxxx", "i-yyyyy"]
instance_public_ips = ["1.2.3.4", "5.6.7.8"]
s3_bucket_name = "my-project-data-abc123"
```

### Step 7: Connect to Your Instance

Use the output to connect:
```bash
ssh -i /path/to/your-key.pem ubuntu@<instance-public-ip>
```

### Step 8: Clean Up

When you're done, destroy the resources:
```bash
terraform destroy
```

Type `yes` to confirm deletion.

## Understanding the Structure

### Modules

Modules are reusable components that encapsulate infrastructure patterns:

```
modules/
├── networking/    # VPC, subnets, routing
├── compute/       # Virtual machines
├── storage/       # Object storage
└── kubernetes/    # Managed Kubernetes
```

Each module:
- Has its own `variables.tf`, `main.tf`, and `outputs.tf`
- Is cloud-agnostic (supports AWS, Azure, GCP)
- Can be used independently or together

### Examples

Examples demonstrate how to use the modules:

```
examples/
├── aws-simple/      # Basic AWS setup
├── azure-simple/    # Basic Azure setup
├── gcp-simple/      # Basic GCP setup
└── multi-cloud/     # Cross-cloud deployment
```

Each example includes:
- Complete working configuration
- Documentation
- Example variable files

### Providers

Provider-specific configurations and resources:

```
providers/
├── aws/        # AWS-specific
├── azure/      # Azure-specific
├── gcp/        # GCP-specific
└── custom/     # Custom provider template
```

## Common Workflows

### Starting a New Project

Use the initialization script:
```bash
./scripts/init-project.sh my-new-app aws
cd projects/my-new-app/environments/dev
```

### Adding a Module

In your `main.tf`:
```hcl
module "networking" {
  source = "../../../modules/networking"
  
  cloud_provider = "aws"
  project_name   = var.project_name
  vpc_cidr       = "10.0.0.0/16"
  
  tags = {
    Environment = "production"
  }
}
```

### Managing Multiple Environments

Create separate directories for each environment:
```
my-project/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   └── terraform.tfvars
│   ├── staging/
│   │   ├── main.tf
│   │   └── terraform.tfvars
│   └── production/
│       ├── main.tf
│       └── terraform.tfvars
```

### Using Remote State

Configure S3 backend in your `main.tf`:
```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "my-project/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

Initialize with backend configuration:
```bash
terraform init -backend-config="bucket=my-terraform-state"
```

### Validating Changes

Before applying:
```bash
# Format code
terraform fmt

# Validate configuration
terraform validate

# Check security
make security

# Generate plan
terraform plan -out=tfplan
```

### Importing Existing Resources

Import an existing resource:
```bash
terraform import aws_instance.example i-1234567890abcdef0
```

## Next Steps

Now that you understand the basics:

1. **Explore other examples**
   - Try the Azure or GCP examples
   - Look at multi-cloud deployment

2. **Learn about modules**
   - Read module documentation
   - Create your own custom modules

3. **Implement best practices**
   - Set up remote state
   - Configure CI/CD pipelines
   - Implement security scanning

4. **Customize for your needs**
   - Add application-specific modules
   - Configure monitoring and logging
   - Set up disaster recovery

## Getting Help

- **Documentation**: Check the [docs/](../) directory
- **Examples**: Review working examples
- **Issues**: Open a [GitHub issue](https://github.com/cywf/the-terraformer/issues)
- **Community**: Join our [Discord](https://discord.gg/YqfWpPuCpG)

## Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [GCP Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Module Development Guide](module-development.md)
- [Security Best Practices](security.md)

---

Ready to deploy? Start with one of our [examples](../examples/) or create a new project with `./scripts/init-project.sh`!
