# Security Best Practices

This guide outlines security best practices when using The Terraformer for Infrastructure as Code.

## Table of Contents

- [General Security Principles](#general-security-principles)
- [Secrets Management](#secrets-management)
- [State File Security](#state-file-security)
- [Network Security](#network-security)
- [Access Control](#access-control)
- [Compliance and Auditing](#compliance-and-auditing)
- [Security Scanning](#security-scanning)

## General Security Principles

### 1. Never Commit Secrets

**NEVER** commit sensitive data to version control:
- API keys
- Passwords
- Private keys
- Certificates
- Access tokens

Use `.gitignore` to prevent accidental commits:
```gitignore
*.tfvars       # Variable files may contain secrets
*.pem          # Private keys
*.key          # Key files
secrets/       # Secret directories
.env           # Environment files
```

### 2. Use Environment Variables

Pass sensitive values via environment variables:

```bash
export TF_VAR_api_key="your-secret-key"
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
```

In Terraform:
```hcl
variable "api_key" {
  description = "API key"
  type        = string
  sensitive   = true
}

# Automatically populated from TF_VAR_api_key
```

### 3. Use Secret Management Services

Retrieve secrets from secure stores:

**AWS Secrets Manager:**
```hcl
data "aws_secretsmanager_secret_version" "api_key" {
  secret_id = "my-api-key"
}

locals {
  api_key = jsondecode(data.aws_secretsmanager_secret_version.api_key.secret_string)["key"]
}
```

**Azure Key Vault:**
```hcl
data "azurerm_key_vault_secret" "api_key" {
  name         = "api-key"
  key_vault_id = azurerm_key_vault.main.id
}
```

**GCP Secret Manager:**
```hcl
data "google_secret_manager_secret_version" "api_key" {
  secret = "api-key"
}
```

## Secrets Management

### HashiCorp Vault Integration

Use Vault for centralized secret management:

```hcl
provider "vault" {
  address = "https://vault.example.com"
}

data "vault_generic_secret" "database" {
  path = "secret/database"
}

resource "aws_db_instance" "main" {
  username = data.vault_generic_secret.database.data["username"]
  password = data.vault_generic_secret.database.data["password"]
}
```

### Mark Variables as Sensitive

Always mark sensitive variables:

```hcl
variable "database_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

output "connection_string" {
  value     = "postgresql://user:${var.database_password}@host:5432/db"
  sensitive = true
}
```

## State File Security

State files contain sensitive information. Protect them!

### 1. Use Remote State with Encryption

**AWS S3 Backend:**
```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "project/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    kms_key_id     = "arn:aws:kms:us-east-1:123456789:key/xxx"
    dynamodb_table = "terraform-locks"
  }
}
```

**Azure Storage Backend:**
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "terraformstate"
    container_name       = "tfstate"
    key                  = "project.tfstate"
    use_azuread_auth     = true
  }
}
```

**GCS Backend:**
```hcl
terraform {
  backend "gcs" {
    bucket  = "my-terraform-state"
    prefix  = "project"
    encryption_key = "base64-encoded-key"
  }
}
```

### 2. Enable State Locking

Prevent concurrent modifications:
- AWS: Use DynamoDB table
- Azure: Automatic with Azure Storage
- GCP: Automatic with GCS

### 3. Restrict State Access

Limit who can access state files:

**AWS S3 Bucket Policy:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::my-terraform-state/*",
        "arn:aws:s3:::my-terraform-state"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
```

### 4. Regular State Backups

Enable versioning on state storage:

```hcl
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  versioning_configuration {
    status = "Enabled"
  }
}
```

## Network Security

### 1. Use Private Subnets

Place sensitive resources in private subnets:

```hcl
module "networking" {
  source = "../../modules/networking"
  
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
}

# Database in private subnet
resource "aws_db_instance" "main" {
  db_subnet_group_name = aws_db_subnet_group.private.name
  publicly_accessible  = false
}
```

### 2. Implement Network Segmentation

Use security groups and network ACLs:

```hcl
resource "aws_security_group" "database" {
  name_prefix = "database-"
  vpc_id      = module.networking.vpc_id
  
  # Only allow access from application tier
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.application.id]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### 3. Enable VPC Flow Logs

Monitor network traffic:

```hcl
resource "aws_flow_log" "vpc" {
  vpc_id          = module.networking.vpc_id
  traffic_type    = "ALL"
  iam_role_arn    = aws_iam_role.flow_log.arn
  log_destination = aws_cloudwatch_log_group.flow_log.arn
}
```

### 4. Use Private Endpoints

Access cloud services privately:

```hcl
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = module.networking.vpc_id
  service_name = "com.amazonaws.us-east-1.s3"
}
```

## Access Control

### 1. Implement Least Privilege

Grant minimal required permissions:

```hcl
resource "aws_iam_role_policy" "app" {
  name = "app-policy"
  role = aws_iam_role.app.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.app.arn}/*"
      }
    ]
  })
}
```

### 2. Enable MFA for Critical Operations

Require MFA for sensitive resources:

```hcl
resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Principal = "*"
        Action = "s3:DeleteObject"
        Resource = "${aws_s3_bucket.main.arn}/*"
        Condition = {
          BoolIfExists = {
            "aws:MultiFactorAuthPresent" = "false"
          }
        }
      }
    ]
  })
}
```

### 3. Use Service Accounts

Prefer service accounts over user accounts:

**AWS:**
```hcl
resource "aws_iam_role" "app" {
  name = "app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}
```

**GCP:**
```hcl
resource "google_service_account" "app" {
  account_id   = "app-service-account"
  display_name = "Application Service Account"
}
```

## Compliance and Auditing

### 1. Enable Cloud Audit Logging

**AWS CloudTrail:**
```hcl
resource "aws_cloudtrail" "main" {
  name                          = "main-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
}
```

**Azure Activity Log:**
```hcl
resource "azurerm_monitor_diagnostic_setting" "subscription" {
  name               = "subscription-logs"
  target_resource_id = data.azurerm_subscription.current.id
  
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  
  log {
    category = "Administrative"
    enabled  = true
  }
}
```

### 2. Tag Resources

Implement consistent tagging:

```hcl
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = var.owner
    CostCenter  = var.cost_center
    Compliance  = var.compliance_level
  }
}
```

### 3. Enable Resource Encryption

**Encrypt at Rest:**
```hcl
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.main.arn
    }
  }
}
```

**Encrypt in Transit:**
```hcl
resource "aws_s3_bucket_policy" "enforce_tls" {
  bucket = aws_s3_bucket.main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "EnforceTLS"
      Effect = "Deny"
      Principal = "*"
      Action = "s3:*"
      Resource = [
        aws_s3_bucket.main.arn,
        "${aws_s3_bucket.main.arn}/*"
      ]
      Condition = {
        Bool = {
          "aws:SecureTransport" = "false"
        }
      }
    }]
  })
}
```

## Security Scanning

### 1. Use tfsec

Scan for security issues:

```bash
# Install tfsec
brew install tfsec

# Scan current directory
tfsec .

# Scan with custom rules
tfsec --custom-check-dir ./custom-checks .
```

### 2. Use Checkov

Policy-as-code scanning:

```bash
# Install checkov
pip install checkov

# Scan Terraform files
checkov -d .

# Scan specific framework
checkov --framework terraform -d .

# Generate report
checkov -d . -o json > security-report.json
```

### 3. Integrate into CI/CD

Add security scanning to your pipeline:

```yaml
# .github/workflows/security.yml
- name: Run tfsec
  uses: aquasecurity/tfsec-action@v1.0.3
  
- name: Run Checkov
  uses: bridgecrewio/checkov-action@master
  with:
    directory: .
    framework: terraform
```

### 4. Regular Security Reviews

Schedule regular security audits:
- Review IAM permissions quarterly
- Audit network rules monthly
- Check for unused resources
- Review access logs
- Update dependencies

## Security Checklist

Use this checklist for security reviews:

- [ ] No secrets in code or version control
- [ ] Sensitive variables marked as sensitive
- [ ] Remote state with encryption enabled
- [ ] State access restricted to authorized users
- [ ] Private subnets for sensitive resources
- [ ] Security groups follow least privilege
- [ ] Encryption at rest enabled
- [ ] Encryption in transit enforced
- [ ] Audit logging enabled
- [ ] Resources properly tagged
- [ ] Service accounts used instead of user accounts
- [ ] MFA required for critical operations
- [ ] Security scanning in CI/CD pipeline
- [ ] Regular security reviews scheduled
- [ ] Incident response plan documented

## Additional Resources

- [Terraform Security Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html#security)
- [AWS Security Best Practices](https://aws.amazon.com/security/best-practices/)
- [Azure Security Best Practices](https://docs.microsoft.com/en-us/azure/security/fundamentals/best-practices-and-patterns)
- [GCP Security Best Practices](https://cloud.google.com/security/best-practices)
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks/)

---

**Remember:** Security is not a one-time task but an ongoing process. Stay informed about security best practices and regularly review your infrastructure.
