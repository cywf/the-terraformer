# Troubleshooting Guide

This guide helps you resolve common issues when using The Terraformer.

## Table of Contents

- [Common Issues](#common-issues)
- [Provider-Specific Issues](#provider-specific-issues)
- [State Management Issues](#state-management-issues)
- [Module Issues](#module-issues)
- [Performance Issues](#performance-issues)
- [Getting Help](#getting-help)

## Common Issues

### "Error: Unsupported Terraform Core version"

**Problem:** Terraform version is too old or too new.

**Solution:**
```bash
# Check your Terraform version
terraform version

# Install correct version
# macOS
brew install terraform@1.6

# Or use tfenv for version management
tfenv install 1.6.0
tfenv use 1.6.0
```

### "Error: Module not installed"

**Problem:** Modules haven't been downloaded.

**Solution:**
```bash
terraform init
```

### "Error: Variables not set"

**Problem:** Required variables are missing.

**Solution:**
```bash
# Create terraform.tfvars
cp example.tfvars terraform.tfvars

# Or set via environment
export TF_VAR_variable_name="value"

# Or pass via command line
terraform apply -var="variable_name=value"
```

### "Error: Backend initialization required"

**Problem:** Backend configuration has changed.

**Solution:**
```bash
terraform init -reconfigure

# Or migrate existing state
terraform init -migrate-state
```

### "Error: Lock Info" / State Locked

**Problem:** Another process is using the state file.

**Solution:**
```bash
# Check if process is actually running
# If not, force unlock (use with caution!)
terraform force-unlock <LOCK_ID>
```

### "Error: Invalid for_each argument"

**Problem:** Using `for_each` with a value that might be null or unknown.

**Solution:**
```hcl
# Bad
for_each = var.some_list

# Good
for_each = var.some_list != null ? toset(var.some_list) : []
```

## Provider-Specific Issues

### AWS Issues

#### "Error: error configuring Terraform AWS Provider: no valid credential sources found"

**Problem:** AWS credentials not configured.

**Solution:**
```bash
# Configure AWS CLI
aws configure

# Or set environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"

# Or use AWS profile
export AWS_PROFILE="your-profile"
```

#### "Error: InvalidParameterException: Security group sg-xxxxx does not exist"

**Problem:** Security group referenced doesn't exist in the VPC.

**Solution:**
- Ensure security group is created before resources that use it
- Check that security group is in the same VPC
- Verify dependencies are correct

#### "Error: ResourceNotFoundException: Bucket does not exist"

**Problem:** S3 bucket name must be globally unique.

**Solution:**
```hcl
# Add random suffix
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket" "main" {
  bucket = "${var.project_name}-${random_string.suffix.result}"
}
```

### Azure Issues

#### "Error: Azure CLI not found"

**Problem:** Azure CLI not installed or not in PATH.

**Solution:**
```bash
# Install Azure CLI
# macOS
brew install azure-cli

# Login
az login
```

#### "Error: Error checking for presence of existing resources"

**Problem:** Missing permissions or resource already exists.

**Solution:**
```bash
# Check your Azure account
az account show

# List available subscriptions
az account list --output table

# Set correct subscription
az account set --subscription "subscription-id"

# Check permissions
az role assignment list --assignee $(az account show --query user.name -o tsv)
```

#### "Error: A resource with the ID already exists"

**Problem:** Resource names must be unique within subscription.

**Solution:**
- Change resource name
- Destroy existing resource
- Import existing resource into state

### GCP Issues

#### "Error: google: could not find default credentials"

**Problem:** GCP credentials not configured.

**Solution:**
```bash
# Initialize gcloud
gcloud init

# Set up application default credentials
gcloud auth application-default login

# Set project
gcloud config set project your-project-id

# Or use service account
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/key.json"
```

#### "Error: Error 403: The caller does not have permission"

**Problem:** Service account lacks required permissions.

**Solution:**
```bash
# Grant necessary roles
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:SERVICE_ACCOUNT_EMAIL" \
  --role="roles/compute.admin"
```

#### "Error: Error 409: The resource already exists"

**Problem:** GCP resource names must be unique within project.

**Solution:**
- Change resource name
- Delete existing resource
- Import into Terraform state

## State Management Issues

### "Error: Error acquiring the state lock"

**Problem:** State file is locked by another process.

**Solution:**
```bash
# Wait for other process to complete

# Or force unlock if process crashed
terraform force-unlock <LOCK_ID>

# Check DynamoDB table (AWS) for stuck locks
aws dynamodb scan --table-name terraform-locks
```

### "Error: Failed to save state"

**Problem:** Cannot write to state backend.

**Solution:**
```bash
# Check backend credentials
# Check network connectivity
# Verify backend configuration

# AWS S3
aws s3 ls s3://your-state-bucket

# Azure
az storage account show --name your-storage-account

# GCP
gsutil ls gs://your-state-bucket
```

### State Drift Detected

**Problem:** Real infrastructure doesn't match state file.

**Solution:**
```bash
# Refresh state
terraform refresh

# Or import resources
terraform import aws_instance.example i-1234567890abcdef0

# Or fix drift manually
terraform apply
```

### "Error: Provider configuration not present"

**Problem:** Provider removed from state but resources remain.

**Solution:**
```bash
# Remove resources from state
terraform state rm 'module.example'

# Or re-add provider to configuration
```

## Module Issues

### "Error: Module not found"

**Problem:** Module source path is incorrect.

**Solution:**
```hcl
# Use correct relative path
module "networking" {
  source = "../../modules/networking"  # Correct
  # source = "../modules/networking"   # Incorrect
}
```

### "Error: Unsupported argument in module block"

**Problem:** Passing variable not defined in module.

**Solution:**
```bash
# Check module's variables.tf
cat modules/networking/variables.tf

# Only pass defined variables
```

### Module Output Not Available

**Problem:** Trying to reference output before module is created.

**Solution:**
```hcl
# Use depends_on
resource "aws_instance" "app" {
  subnet_id = module.networking.public_subnet_ids[0]
  
  depends_on = [module.networking]
}
```

## Performance Issues

### Terraform is Slow

**Problem:** Large state file or many resources.

**Solutions:**
```bash
# Use parallelism flag
terraform apply -parallelism=20

# Use -target for specific resources
terraform apply -target=module.networking

# Split into multiple state files
# Use separate configurations for different environments
```

### Plan Takes Too Long

**Problem:** Provider API calls are slow.

**Solutions:**
```bash
# Use -refresh=false to skip refresh
terraform plan -refresh=false

# Reduce number of resources in single configuration
# Use data sources instead of remote state when possible
```

## Debugging

### Enable Debug Logging

```bash
# Set log level
export TF_LOG=DEBUG
export TF_LOG_PATH=./terraform-debug.log

# Run Terraform
terraform apply

# Check log file
less terraform-debug.log
```

### Validate Configuration

```bash
# Format check
terraform fmt -check -recursive

# Validation
terraform validate

# Show plan in JSON
terraform plan -out=tfplan.binary
terraform show -json tfplan.binary | jq .
```

### Check Provider Issues

```bash
# AWS
aws sts get-caller-identity
aws ec2 describe-vpcs

# Azure
az account show
az group list

# GCP
gcloud auth list
gcloud projects list
```

## Common Error Messages

### "Error: Invalid reference"

```hcl
# Bad - referencing resource that doesn't exist
subnet_id = aws_subnet.private.id

# Good - checking if resource exists
subnet_id = length(aws_subnet.private) > 0 ? aws_subnet.private[0].id : null
```

### "Error: Cycle"

```hcl
# Bad - circular dependency
resource "aws_instance" "app" {
  subnet_id = aws_subnet.private.id
}

resource "aws_subnet" "private" {
  vpc_id = aws_instance.app.vpc_id  # Circular!
}

# Good - break the cycle
resource "aws_subnet" "private" {
  vpc_id = aws_vpc.main.id
}

resource "aws_instance" "app" {
  subnet_id = aws_subnet.private.id
}
```

### "Error: Invalid value for variable"

```hcl
# Check variable type matches
variable "instance_count" {
  type = number
}

# Pass correct type
instance_count = 3      # Correct
# instance_count = "3"  # Incorrect - string instead of number
```

## Recovery Procedures

### Lost State File

**If you have a backup:**
```bash
# Restore from backup
cp terraform.tfstate.backup terraform.tfstate
```

**If no backup:**
```bash
# Import all resources manually
terraform import aws_vpc.main vpc-xxxxx
terraform import aws_subnet.public[0] subnet-xxxxx
# ... continue for all resources
```

### Corrupted State

```bash
# Try to recover
terraform state pull > backup.tfstate
terraform state push backup.tfstate

# Or rebuild from backup
```

### Accidentally Destroyed Resources

```bash
# Re-apply configuration
terraform apply

# Or restore from cloud provider backups
# AWS: Use EBS snapshots, RDS snapshots
# Azure: Use backup vaults
# GCP: Use persistent disk snapshots
```

## Getting Help

### Information to Provide

When seeking help, include:

1. **Terraform version**: `terraform version`
2. **Provider versions**: Check `terraform.lock.hcl`
3. **Error message**: Full error output
4. **Configuration**: Relevant `.tf` files (redact secrets!)
5. **Steps to reproduce**: What commands you ran

### Where to Get Help

- **GitHub Issues**: [Report bugs](https://github.com/cywf/the-terraformer/issues)
- **Discussions**: [Ask questions](https://github.com/cywf/the-terraformer/discussions)
- **Discord**: [Community chat](https://discord.gg/YqfWpPuCpG)
- **Terraform Forum**: [HashiCorp Discuss](https://discuss.hashicorp.com/c/terraform-core)

### Useful Commands

```bash
# Show detailed error info
terraform apply -json | jq .

# List all resources in state
terraform state list

# Show specific resource
terraform state show aws_instance.example

# Validate without cloud API calls
terraform validate

# Show providers
terraform providers

# Show current workspace
terraform workspace show
```

## Prevention

### Best Practices to Avoid Issues

1. **Always run `terraform plan` before `apply`**
2. **Use version control for all `.tf` files**
3. **Never manually modify resources managed by Terraform**
4. **Use remote state with locking**
5. **Test changes in dev/staging before production**
6. **Keep Terraform and providers up to date**
7. **Use consistent naming conventions**
8. **Document your infrastructure**
9. **Implement CI/CD with validation**
10. **Regular backups of state files**

---

**Still stuck?** Open an issue on GitHub with full details!
