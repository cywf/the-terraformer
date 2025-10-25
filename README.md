![The Terraformer](assets/images/ai_terraformer.png)

[![Release](https://img.shields.io/badge/Release-v1.0.0-blue)](https://github.com/cywf/the-terraformer/releases)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.0-purple)](https://www.terraform.io/)

# The Terraformer

A production-ready, multi-cloud Infrastructure as Code (IaC) template repository that enables rapid project onboarding with Terraform. Deploy your applications across AWS, Azure, GCP, or build custom providers for specialized infrastructure needs.

## 🚀 Features

- **Multi-Cloud Support**: Pre-built modules for AWS, Azure, and GCP
- **Reusable Modules**: Networking, Compute, Storage, and Kubernetes resources
- **Custom Provider Framework**: Template and guide for building your own Terraform providers
- **Production-Ready**: Security best practices, proper state management, and comprehensive documentation
- **Quick Start Examples**: Working configurations for each cloud provider
- **Well-Documented**: Extensive guides and inline documentation
- **CI/CD Ready**: GitHub Actions workflows for validation and testing

## 📋 Table of Contents

- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Available Modules](#available-modules)
- [Examples](#examples)
- [Custom Providers](#custom-providers)
- [Best Practices](#best-practices)
- [Documentation](#documentation)
- [Contributing](#contributing)
- [License](#license)

## 🎯 Quick Start

### Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.0
- Cloud provider CLI tools (AWS CLI, Azure CLI, or gcloud SDK)
- Valid cloud provider credentials

### Using the Template

1. **Use this template** to create a new repository
   ```bash
   # Or clone directly
   git clone https://github.com/cywf/the-terraformer.git my-infrastructure
   cd my-infrastructure
   ```

2. **Choose an example** that matches your cloud provider
   ```bash
   cd examples/aws-simple  # or azure-simple, gcp-simple
   ```

3. **Configure your variables**
   ```bash
   cp example.tfvars terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

4. **Initialize and deploy**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

### Creating a New Project

Use the initialization script to quickly set up a new project:

```bash
./scripts/init-project.sh my-new-project aws
```

This creates a new project directory with:
- Provider configuration
- Module imports
- Variable definitions
- Example configurations

## 📁 Project Structure

```
the-terraformer/
├── modules/              # Reusable Terraform modules
│   ├── networking/       # VPC/VNet resources
│   ├── compute/          # VM/Instance resources
│   ├── storage/          # Object storage (S3, Blob, GCS)
│   └── kubernetes/       # Managed Kubernetes (EKS, AKS, GKE)
├── providers/            # Provider configurations
│   ├── aws/             # AWS-specific resources
│   ├── azure/           # Azure-specific resources
│   ├── gcp/             # GCP-specific resources
│   └── custom/          # Custom provider template
├── examples/            # Complete working examples
│   ├── aws-simple/      # Basic AWS infrastructure
│   ├── azure-simple/    # Basic Azure infrastructure
│   ├── gcp-simple/      # Basic GCP infrastructure
│   └── multi-cloud/     # Multi-cloud deployment
├── docs/               # Documentation
├── scripts/            # Utility scripts
└── .github/           # CI/CD workflows
```

## 🧩 Available Modules

### Networking Module
Creates VPC/VNet with public and private subnets, internet gateways, and routing tables.

**Supports**: AWS, Azure, GCP

```hcl
module "networking" {
  source = "../../modules/networking"
  
  cloud_provider = "aws"
  project_name   = "my-project"
  vpc_cidr       = "10.0.0.0/16"
}
```

### Compute Module
Provisions virtual machines or compute instances with configurable sizing and networking.

**Supports**: AWS (EC2), Azure (VM), GCP (Compute Engine)

```hcl
module "compute" {
  source = "../../modules/compute"
  
  cloud_provider = "aws"
  instance_count = 3
  instance_type  = "t3.medium"
  subnet_ids     = module.networking.public_subnet_ids
}
```

### Storage Module
Creates object storage buckets with encryption and versioning.

**Supports**: AWS (S3), Azure (Blob Storage), GCP (Cloud Storage)

```hcl
module "storage" {
  source = "../../modules/storage"
  
  cloud_provider    = "aws"
  project_name      = "my-project"
  enable_versioning = true
}
```

### Kubernetes Module
Deploys managed Kubernetes clusters.

**Supports**: AWS (EKS), Azure (AKS), GCP (GKE)

```hcl
module "kubernetes" {
  source = "../../modules/kubernetes"
  
  cloud_provider = "aws"
  node_count     = 3
  node_instance_type = "t3.medium"
  subnet_ids     = module.networking.private_subnet_ids
}
```

## 📚 Examples

### AWS Simple
Basic AWS infrastructure with VPC, EC2 instances, and S3 bucket.
[View Example →](examples/aws-simple/)

### Azure Simple
Basic Azure infrastructure with VNet, VMs, and Storage Account.
[View Example →](examples/azure-simple/)

### GCP Simple
Basic GCP infrastructure with VPC, Compute Instances, and Cloud Storage.
[View Example →](examples/gcp-simple/)

### Multi-Cloud
Deploy resources across multiple cloud providers simultaneously.
[View Example →](examples/multi-cloud/)

## 🔧 Custom Providers

The Terraformer includes a complete framework for building custom Terraform providers. This is perfect for:

- Integrating with proprietary APIs
- Managing internal infrastructure
- Implementing custom business logic
- Specialized deployment workflows

**Getting Started with Custom Providers:**

1. Navigate to the custom provider template:
   ```bash
   cd providers/custom/template
   ```

2. Follow the [Custom Provider Guide](providers/custom/README.md)

3. Implement your provider logic in Go

4. Build and test locally

See [Custom Provider Documentation](docs/custom-providers.md) for detailed instructions.

## 🛡️ Best Practices

### State Management
- **Use remote state**: Store Terraform state in S3/Azure Storage/GCS with locking
- **Separate environments**: Use workspaces or separate state files for dev/staging/prod
- **State encryption**: Enable encryption at rest for state files

### Security
- **Never commit secrets**: Use environment variables or secret management services
- **Least privilege**: Use minimal IAM/RBAC permissions
- **Enable encryption**: Encrypt resources at rest and in transit
- **Regular updates**: Keep providers and modules up to date

### Code Organization
- **Modular design**: Use modules for reusable components
- **Clear naming**: Use consistent naming conventions
- **Documentation**: Document variables, outputs, and module purposes
- **Version pinning**: Pin provider and module versions

### Testing
- **Validation**: Run `terraform validate` before applying
- **Plan review**: Always review plans before applying
- **Automated testing**: Use tools like Terratest for module testing
- **CI/CD**: Implement automated validation in pipelines

## 📖 Documentation

Comprehensive guides are available in the [docs/](docs/) directory:

- [Getting Started Guide](docs/getting-started.md)
- [Module Development](docs/module-development.md)
- [Custom Providers](docs/custom-providers.md)
- [Multi-Cloud Deployment](docs/multi-cloud.md)
- [Security Best Practices](docs/security.md)
- [Troubleshooting](docs/troubleshooting.md)

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details on:

- Code of conduct
- Development setup
- Submitting pull requests
- Coding standards
- Testing requirements

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- HashiCorp for Terraform
- Cloud provider communities
- All contributors to this project

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/cywf/the-terraformer/issues)
- **Discussions**: [GitHub Discussions](https://github.com/cywf/the-terraformer/discussions)
- **Discord**: [Join our Discord](https://discord.gg/YqfWpPuCpG)

---

**Made with ❤️ by the community**
