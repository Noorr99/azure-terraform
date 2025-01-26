output "data_factory_id" {
  description = "The ID of the Data Factory."
  value       = azurerm_data_factory.this.id
}

output "data_factory_name" {
  description = "The name of the Data Factory."
  value       = azurerm_data_factory.this.name
}

output "azure_ir_id" {
  description = "The ID of the Azure Integration Runtime."
  value       = azurerm_data_factory_integration_runtime_managed.azure_ir.id
}

output "self_hosted_ir_id" {
  description = "The ID of the Self-Hosted Integration Runtime."
  value       = azurerm_data_factory_integration_runtime_self_hosted.self_hosted_ir.id
}
