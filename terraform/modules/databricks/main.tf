terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }

  required_version = ">= 0.14.9"
}

resource "azurerm_databricks_workspace" "databricks" {
  name                         = var.name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  sku                          = var.sku
  managed_resource_group_name  = var.managed_resource_group_name
  tags                         = var.tags

  custom_parameters {
    virtual_network_id  = var.virtual_network_id
    public_subnet_name  = var.public_subnet_name
    private_subnet_name = var.private_subnet_name
  }
}
