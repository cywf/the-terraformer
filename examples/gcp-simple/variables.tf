variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "gcp_zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "gcp-example"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "instance_count" {
  description = "Number of compute instances"
  type        = number
  default     = 2
}

variable "instance_type" {
  description = "Compute instance machine type"
  type        = string
  default     = "e2-micro"
}

variable "gcp_image" {
  description = "Boot disk image"
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2204-lts"
}

variable "admin_username" {
  description = "Admin username"
  type        = string
  default     = "gcpuser"
}

variable "ssh_public_key" {
  description = "SSH public key content"
  type        = string
  default     = ""
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Restrict in production!
}
