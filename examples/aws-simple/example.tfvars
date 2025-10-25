# Example variable values - copy this to terraform.tfvars and customize

aws_region   = "us-east-1"
project_name = "my-aws-project"
environment  = "dev"

# Network configuration
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
availability_zones   = ["us-east-1a", "us-east-1b"]

# Compute configuration
instance_count = 2
instance_type  = "t3.micro"
aws_ami_id     = "ami-0c55b159cbfafe1f0" # Replace with AMI in your region
ssh_key_name   = "my-key-pair"           # Replace with your key pair name

# Security
allowed_ssh_cidrs = ["your.ip.address.here/32"] # Restrict to your IP in production!
