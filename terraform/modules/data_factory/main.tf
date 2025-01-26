resource "azurerm_data_factory" "this" {
  name                = var.data_factory_name
  resource_group_name = var.resource_group_name
  location            = var.location

  # Now you can assign tags from the variable:
  tags = var.tags
}
