# AWS Simple Example

This example demonstrates how to use The Terraformer template to deploy basic infrastructure on AWS.

## What Gets Created

- VPC with public and private subnets across 2 availability zones
- Internet Gateway for public subnet internet access
- EC2 instances in public subnets
- Security group allowing SSH, HTTP, and HTTPS
- S3 bucket with versioning and encryption

## Prerequisites

1. AWS CLI configured with credentials
2. Terraform >= 1.0
3. An EC2 key pair created in your target region

## Usage

1. Copy the example.tfvars file:
```bash
cp example.tfvars terraform.tfvars
```

2. Edit terraform.tfvars with your values:
```hcl
aws_region   = "us-east-1"
project_name = "my-project"
aws_ami_id   = "ami-0c55b159cbfafe1f0"  # Ubuntu 22.04 LTS in us-east-1
ssh_key_name = "my-key-pair"
```

3. Initialize Terraform:
```bash
terraform init
```

4. Plan the deployment:
```bash
terraform plan
```

5. Apply the configuration:
```bash
terraform apply
```

## Getting an AMI ID

To find the latest Ubuntu AMI in your region:
```bash
aws ec2 describe-images \
  --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" \
  --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' \
  --output text
```

## Connecting to Instances

After deployment, connect to your instances:
```bash
ssh -i /path/to/your/key.pem ubuntu@<instance-public-ip>
```

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

## Estimated Costs

- VPC: Free
- EC2 t3.micro instances: ~$0.01/hour each
- S3 bucket: ~$0.023/GB/month + requests
- Internet Gateway: Free
- Data transfer: Varies

Total estimate for 2 t3.micro instances: ~$15/month (excluding data transfer)
