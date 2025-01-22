terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
  required_version = ">= 0.14.9"
}

#############################
# Create NSG for Databricks Public Subnet
#############################
resource "azurerm_network_security_group" "public_nsg" {
  name                = "${var.public_subnet_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "AllowDatabricksPublicInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#############################
# Create NSG for Databricks Private Subnet
#############################
resource "azurerm_network_security_group" "private_nsg" {
  name                = "${var.private_subnet_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "AllowDatabricksPrivateInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#############################
# Look up the Databricks Public Subnet
#############################
data "azurerm_subnet" "public_subnet" {
  name                 = var.public_subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.resource_group_name
}

#############################
# Look up the Databricks Private Subnet
#############################
data "azurerm_subnet" "private_subnet" {
  name                 = var.private_subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.resource_group_name
}

#############################
# Associate NSG to Public Subnet
#############################
resource "azurerm_subnet_network_security_group_association" "public_association" {
  subnet_id                 = data.azurerm_subnet.public_subnet.id
  network_security_group_id = azurerm_network_security_group.public_nsg.id
}

#############################
# Associate NSG to Private Subnet
#############################
resource "azurerm_subnet_network_security_group_association" "private_association" {
  subnet_id                 = data.azurerm_subnet.private_subnet.id
  network_security_group_id = azurerm_network_security_group.private_nsg.id
}

#############################
# Create Databricks Workspace with VNet Injection
#############################
resource "azurerm_databricks_workspace" "databricks" {
  name                        = var.name
  resource_group_name         = var.resource_group_name
  location                    = var.location
  sku                         = var.sku
  managed_resource_group_name = var.managed_resource_group_name 
  tags                        = var.tags

  custom_parameters {
    virtual_network_id                                  = var.virtual_network_id
    public_subnet_name                                  = var.public_subnet_name
    public_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.public_association.id
    private_subnet_name                                 = var.private_subnet_name
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.private_association.id
  }

  lifecycle {
    ignore_changes = [tags]
  }
}
