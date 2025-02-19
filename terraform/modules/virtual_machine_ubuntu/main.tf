terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
  required_version = ">= 0.14.9"
}

#############################
# Public IP for Ubuntu VM
#############################
resource "azurerm_public_ip" "ubuntu_public_ip" {
  count               = var.ubuntu_vm_public_ip ? 1 : 0
  name                = "${var.ubuntu_vm_name}-publicip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
  domain_name_label   = lower(var.ubuntu_domain_name_label)
  tags                = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

#############################
# Network Interface for Ubuntu VM
#############################
resource "azurerm_network_interface" "ubuntu_nic" {
  name                = "${var.ubuntu_vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
//    public_ip_address_id          = try(azurerm_public_ip.ubuntu_public_ip[0].id, null)
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

#############################
# Network Security Group for Ubuntu VM (Allow SSH)
#############################
resource "azurerm_network_security_group" "ubuntu_nsg" {
  name                = "nsg-${var.ubuntu_vm_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

#############################
# NSG Association for the NIC
#############################
resource "azurerm_network_interface_security_group_association" "ubuntu_nic_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.ubuntu_nic.id
  network_security_group_id = azurerm_network_security_group.ubuntu_nsg.id
}

#############################
# Linux Virtual Machine (Ubuntu)
#############################
resource "azurerm_linux_virtual_machine" "ubuntu_vm" {
  count                = var.ubuntu_vm_count
  name                 = var.ubuntu_vm_name
  location             = var.location
  resource_group_name  = var.resource_group_name
  size                 = var.ubuntu_vm_size
  admin_username       = var.ubuntu_admin_username
  admin_password       = var.ubuntu_admin_password
  disable_password_authentication = false
  network_interface_ids = [azurerm_network_interface.ubuntu_nic.id]
  secure_boot_enabled = true
  vtpm_enabled = true  
  os_disk {
    name                 = "${var.ubuntu_vm_name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = var.ubuntu_vm_os_disk_storage_account_type
  }
  
  source_image_reference {
    publisher = lookup(var.ubuntu_vm_os_disk_image, "publisher", null)
    offer     = lookup(var.ubuntu_vm_os_disk_image, "offer", null)
    sku       = lookup(var.ubuntu_vm_os_disk_image, "sku", null)
    version   = lookup(var.ubuntu_vm_os_disk_image, "version", null)
  }
  
  tags = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}
