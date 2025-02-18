terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
  required_version = ">= 0.14.9"
}

#############################
# Public IP
#############################
resource "azurerm_public_ip" "public_ip" {
  name                = "${var.name}PublicIp"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
  domain_name_label   = lower(var.domain_name_label)
  count               = var.public_ip ? 1 : 0
  tags                = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

#############################
# Network Security Group (allow RDP and Oracle On-Prem outbound)
#############################
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "RDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Outbound_Oracle_Onprem"
    priority                   = 1011
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "1521"
    source_address_prefix      = "*"
    destination_address_prefix = "192.168.6.88/32"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

#############################
# Network Interface
#############################
resource "azurerm_network_interface" "nic" {
  name                = "${var.name}Nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "Configuration"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = try(azurerm_public_ip.public_ip[0].id, null)
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

#############################
# NSG Association for the NIC
#############################
resource "azurerm_network_interface_security_group_association" "nsg_association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
  
  depends_on = [
    azurerm_network_interface.nic,
    azurerm_network_security_group.nsg
  ]
}

#############################
# Windows Virtual Machine
#############################
resource "azurerm_windows_virtual_machine" "virtual_machine" {
  name                  = "${var.name}-${var.index_str}"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = var.size
  admin_username        = var.vm_user
  admin_password        = var.admin_password
  computer_name         = var.name
  tags                  = var.tags
  zone                  = var.zone
//  availability_set_id = var.availability_set_id
/*
  security_type       = "TrustedLaunch"
  enable_secure_boot  = true
  enable_vtpm         = true
*/
  security_type = "TrustedLaunch"

  uefi_settings {
    secure_boot_enabled = true
    vtpm_enabled        = true
  }
  os_disk {
    name                 = "${var.name}OsDisk"
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_storage_account_type
  }

  source_image_reference {
    publisher = lookup(var.os_disk_image, "publisher", null)
    offer     = lookup(var.os_disk_image, "offer", null)
    sku       = lookup(var.os_disk_image, "sku", null)
    version   = lookup(var.os_disk_image, "version", null)
  }

  lifecycle {
    ignore_changes = [tags]
  }

  depends_on = [
    azurerm_network_interface.nic,
    azurerm_network_security_group.nsg,
  ]
}
