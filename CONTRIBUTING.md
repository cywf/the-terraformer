# Contributing to The Terraformer

Thank you for your interest in contributing to The Terraformer! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)
- [Community](#community)

## Code of Conduct

We are committed to providing a welcoming and inclusive experience for everyone. Please be respectful and professional in all interactions.

### Our Standards

- Use welcoming and inclusive language
- Be respectful of differing viewpoints and experiences
- Gracefully accept constructive criticism
- Focus on what is best for the community
- Show empathy towards other community members

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/your-username/the-terraformer.git
   cd the-terraformer
   ```
3. **Add upstream remote**:
   ```bash
   git remote add upstream https://github.com/cywf/the-terraformer.git
   ```

## Development Setup

### Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.0
- [Go](https://golang.org/doc/install) >= 1.20 (for custom provider development)
- Git
- Cloud provider accounts (for testing)

### Environment Setup

1. Install Terraform:
   ```bash
   # macOS
   brew install terraform
   
   # Linux
   wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
   unzip terraform_1.6.0_linux_amd64.zip
   sudo mv terraform /usr/local/bin/
   ```

2. Configure cloud provider credentials:
   ```bash
   # AWS
   aws configure
   
   # Azure
   az login
   
   # GCP
   gcloud auth application-default login
   ```

3. Install pre-commit hooks (recommended):
   ```bash
   pip install pre-commit
   pre-commit install
   ```

## How to Contribute

### Reporting Bugs

Before creating a bug report:
- Check the existing issues to avoid duplicates
- Collect relevant information (Terraform version, provider versions, error messages)

When creating a bug report, include:
- Clear, descriptive title
- Steps to reproduce
- Expected behavior
- Actual behavior
- Environment details
- Relevant code snippets or configurations

### Suggesting Enhancements

Enhancement suggestions are welcome! Please:
- Use a clear, descriptive title
- Provide detailed description of the proposed feature
- Explain why this enhancement would be useful
- Include code examples if applicable

### Code Contributions

We welcome code contributions! Here are the areas where you can help:

1. **New Modules**: Add support for additional cloud services
2. **Provider Support**: Add new cloud provider integrations
3. **Documentation**: Improve or add documentation
4. **Examples**: Add new example configurations
5. **Bug Fixes**: Fix reported issues
6. **Tests**: Add or improve test coverage

## Coding Standards

### Terraform Code Style

Follow the [Terraform Style Guide](https://www.terraform.io/language/syntax/style):

- Use 2 spaces for indentation
- Use lowercase with underscores for resource names
- Group related resources together
- Add comments for complex logic
- Use variables for configurable values
- Define outputs for important values

Example:
```hcl
# Good
resource "aws_instance" "web_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  
  tags = {
    Name = "${var.project_name}-web-server"
  }
}

# Bad
resource "aws_instance" "WebServer" {
ami="ami-12345"
instance_type="t2.micro"
}
```

### Documentation

- Use clear, concise language
- Provide examples for complex concepts
- Keep README files up to date
- Document all variables and outputs
- Include usage examples in module READMEs

### Commit Messages

Write clear commit messages:

```
<type>: <subject>

<body>

<footer>
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

Example:
```
feat: add Azure Kubernetes module

- Implement AKS cluster creation
- Add node pool configuration
- Include RBAC setup
- Add module documentation

Closes #123
```

## Testing

### Module Testing

Before submitting:

1. **Validate syntax**:
   ```bash
   terraform fmt -recursive
   terraform validate
   ```

2. **Test locally**:
   ```bash
   cd examples/your-example
   terraform init
   terraform plan
   # Review the plan carefully
   terraform apply
   # Verify resources
   terraform destroy
   ```

3. **Check for security issues**:
   ```bash
   # Install tfsec
   brew install tfsec
   
   # Run security scan
   tfsec .
   ```

### Integration Testing

For significant changes:
- Test with multiple cloud providers
- Test different variable combinations
- Verify module outputs
- Check resource dependencies

## Pull Request Process

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**:
   - Follow coding standards
   - Add tests if applicable
   - Update documentation

3. **Commit your changes**:
   ```bash
   git add .
   git commit -m "feat: add new feature"
   ```

4. **Keep your branch updated**:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

5. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a Pull Request**:
   - Use a clear, descriptive title
   - Reference any related issues
   - Describe your changes in detail
   - Include testing steps
   - Add screenshots if applicable

### PR Review Process

- Maintainers will review your PR
- Address any feedback or requested changes
- Once approved, your PR will be merged

### PR Checklist

- [ ] Code follows project style guidelines
- [ ] Documentation is updated
- [ ] Tests pass locally
- [ ] Commit messages are clear
- [ ] No secrets or sensitive data in code
- [ ] Changes are backward compatible (or clearly documented)

## Module Development Guidelines

When creating new modules:

1. **Use consistent structure**:
   ```
   module-name/
   ├── main.tf
   ├── variables.tf
   ├── outputs.tf
   ├── README.md
   └── examples/
   ```

2. **Include comprehensive README**:
   - Module description
   - Usage examples
   - Input variables table
   - Output values table
   - Requirements and dependencies

3. **Make modules flexible**:
   - Use variables for customization
   - Provide sensible defaults
   - Support multiple use cases
   - Document all options

4. **Follow security best practices**:
   - Enable encryption by default
   - Use least privilege permissions
   - Validate inputs
   - Document security considerations

## Community

### Getting Help

- **Discord**: [Join our Discord server](https://discord.gg/YqfWpPuCpG)
- **Discussions**: [GitHub Discussions](https://github.com/cywf/the-terraformer/discussions)
- **Issues**: [GitHub Issues](https://github.com/cywf/the-terraformer/issues)

### Recognition

Contributors will be:
- Listed in our contributors section
- Credited in release notes
- Recognized in our community channels

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to The Terraformer! 🎉
