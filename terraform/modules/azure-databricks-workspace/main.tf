terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }

  required_version = ">= 0.14.9"
}

resource "azurerm_databricks_workspace" "module-databricks" {
  name                = var.workspace_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "standard"
  managed_resource_group_name = "${var.workspace_name}-managed-rg"

  network {
    no_public_ip       = false
    private_subnet_id  = var.private_subnet_id
    public_subnet_id   = var.public_subnet_id
    virtual_network_id = var.vnet_id
  }

  tags = var.tags
}
