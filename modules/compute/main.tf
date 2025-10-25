# Compute Module
# This module creates compute instances across AWS, Azure, and GCP

terraform {
  required_version = ">= 1.0"
}

# AWS EC2 Instance
resource "aws_instance" "main" {
  count = var.cloud_provider == "aws" ? var.instance_count : 0

  ami                    = var.aws_ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids[count.index % length(var.subnet_ids)]
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.ssh_key_name

  root_block_device {
    volume_size           = var.disk_size_gb
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  user_data = var.user_data_script

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-instance-${count.index + 1}"
    }
  )
}

# Azure Virtual Machine
resource "azurerm_network_interface" "main" {
  count = var.cloud_provider == "azure" ? var.instance_count : 0

  name                = "${var.project_name}-nic-${count.index + 1}"
  location            = var.azure_location
  resource_group_name = var.azure_resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_ids[count.index % length(var.subnet_ids)]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.assign_public_ip ? azurerm_public_ip.main[count.index].id : null
  }

  tags = var.tags
}

resource "azurerm_public_ip" "main" {
  count = var.cloud_provider == "azure" && var.assign_public_ip ? var.instance_count : 0

  name                = "${var.project_name}-pip-${count.index + 1}"
  location            = var.azure_location
  resource_group_name = var.azure_resource_group_name
  allocation_method   = "Static"

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "main" {
  count = var.cloud_provider == "azure" ? var.instance_count : 0

  name                = "${var.project_name}-vm-${count.index + 1}"
  location            = var.azure_location
  resource_group_name = var.azure_resource_group_name
  size                = var.instance_type
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.main[count.index].id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = var.disk_size_gb
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  custom_data = var.user_data_script != "" ? base64encode(var.user_data_script) : null

  tags = var.tags
}

# GCP Compute Instance
resource "google_compute_instance" "main" {
  count = var.cloud_provider == "gcp" ? var.instance_count : 0

  name         = "${var.project_name}-instance-${count.index + 1}"
  machine_type = var.instance_type
  zone         = var.gcp_zone
  project      = var.gcp_project_id

  boot_disk {
    initialize_params {
      image = var.gcp_image
      size  = var.disk_size_gb
      type  = "pd-ssd"
    }
  }

  network_interface {
    subnetwork = var.subnet_ids[count.index % length(var.subnet_ids)]

    dynamic "access_config" {
      for_each = var.assign_public_ip ? [1] : []
      content {
        // Ephemeral public IP
      }
    }
  }

  metadata = {
    ssh-keys = var.ssh_public_key != "" ? "${var.admin_username}:${var.ssh_public_key}" : null
  }

  metadata_startup_script = var.user_data_script

  tags = concat(
    [var.project_name],
    var.gcp_network_tags
  )

  labels = var.tags
}
