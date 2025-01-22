output "databricks_workspace_id" {
  description = "The ID of the Databricks workspace."
  value       = azurerm_databricks_workspace.databricks.id
}

output "databricks_workspace_url" {
  description = "The URL of the Databricks workspace."
  value       = azurerm_databricks_workspace.databricks.workspace_url
}
