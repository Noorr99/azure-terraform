resource "azurerm_data_factory" "this" {
  name                = var.data_factory_name
  resource_group_name = var.resource_group_name
  location            = var.location

  # Optional arguments, if needed:
  # public_network_enabled             = true
  # managed_virtual_network_enabled    = false
  # tags                               = { environment = "dev" }
}
