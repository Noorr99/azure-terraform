//
// Azure Data Factory
//
resource "azurerm_data_factory" "this" {
  name                = var.data_factory_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

//
// Azure Integration Runtime (Managed)
//
resource "azurerm_data_factory_integration_runtime_managed" "azure_ir" {
  name            = "${var.data_factory_name}-managed-ir"
  data_factory_id = azurerm_data_factory.this.id
  
  # Required argument:
  node_size = "Standard_D8_v3" 

  # Optional:
  # description = "Managed IR for data movement in Azure."
  # number_of_nodes = 4
  # max_parallel_executions_per_node = 2
  # vnet_integration {
  #   # If you want to attach it to a Data Factory Managed VNet
  # }
}

//
// Self-Hosted Integration Runtime
// (Remove if you don't need on-prem data movement)
//
resource "azurerm_data_factory_integration_runtime_self_hosted" "self_hosted_ir" {
  name            = "${var.data_factory_name}-selfhosted-ir"
  data_factory_id = azurerm_data_factory.this.id

  # Optional:
  # description = "Self-Hosted IR for on-prem or VM-based data movement."
}
