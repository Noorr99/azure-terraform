//
// Azure Data Factory
//
resource "azurerm_data_factory" "this" {
  name                = var.data_factory_name
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = var.tags
}

//
// Azure Integration Runtime (Managed)
//
resource "azurerm_data_factory_integration_runtime_managed" "azure_ir" {
  name                = "${var.data_factory_name}-azureir"
  data_factory_name   = azurerm_data_factory.this.name
  resource_group_name = var.resource_group_name
  location            = var.location
  description         = "Azure Integration Runtime for data movement in Azure."

  # Example compute settings: 8 cores, 10 minute time-to-live
  compute_properties {
    compute_type = "General"
    core_count   = 8
    time_to_live = 10
  }

  tags = var.tags
}

//
// Self-Hosted Integration Runtime
// (If you need on-prem or VM-based data movement.)
//
resource "azurerm_data_factory_integration_runtime_self_hosted" "self_hosted_ir" {
  name                = "${var.data_factory_name}-selfhostedir"
  data_factory_name   = azurerm_data_factory.this.name
  resource_group_name = var.resource_group_name
  location            = var.location
  description         = "Self-Hosted IR for on-prem or VM-based data movement."

  tags = var.tags
}
