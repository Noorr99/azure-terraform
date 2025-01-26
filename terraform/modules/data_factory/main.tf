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
// Per the 3.x provider docs, these arguments are required:
// - name
// - data_factory_id
// - node_size
// - location
//
resource "azurerm_data_factory_integration_runtime_managed" "azure_ir" {
  name            = "${var.data_factory_name}-managed-ir"
  data_factory_id = azurerm_data_factory.this.id
  location        = var.location
  node_size       = "Standard_D8_v3"

  // Optional properties you can add:
  // number_of_nodes = 2
  // description     = "Azure-managed IR for data movement within Azure"
  // max_parallel_executions_per_node = 1
}

//
// Self-Hosted Integration Runtime (Optional)
//
// Per the 3.x provider docs, only name, data_factory_id are required.
// "location", "tags", and "resource_group_name" are unsupported for self-hosted.
//
resource "azurerm_data_factory_integration_runtime_self_hosted" "self_hosted_ir" {
  name            = "${var.data_factory_name}-selfhosted-ir"
  data_factory_id = azurerm_data_factory.this.id

  // Optional:
  // description = "Self-Hosted IR for on-prem or VM-based data movement."
}
