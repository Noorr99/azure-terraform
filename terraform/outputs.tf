output "cognitive_service_endpoint" {
  description = "The endpoint URL of the Azure Cognitive Service."
  value       = azurerm_cognitive_services_account.cognitive_service.endpoint
}

output "cognitive_service_primary_key" {
  description = "The primary access key for the Azure Cognitive Service."
  value       = azurerm_cognitive_services_account.cognitive_service.primary_access_key
  sensitive   = true
}

output "cognitive_service_resource_id" {
  description = "The resource ID of the Azure Cognitive Service."
  value       = azurerm_cognitive_services_account.cognitive_service.id
}

output "cognitive_service_identity_principal_id" {
  description = "The principal ID of the managed identity for the Cognitive Service."
  value       = azurerm_cognitive_services_account.cognitive_service.identity[0].principal_id
}

output "cognitive_service_identity_tenant_id" {
  description = "The tenant ID associated with the managed identity for the Cognitive Service."
  value       = azurerm_cognitive_services_account.cognitive_service.identity[0].tenant_id
}
