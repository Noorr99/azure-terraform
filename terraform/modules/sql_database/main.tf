# SQL Server Resource
resource "azurerm_sql_server" "sql_server" {
  name                         = var.sql_server_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password
  tags                         = var.tags
}

# SQL Database Resource
resource "azurerm_sql_database" "sql_database" {
  name                = var.sql_database_name
  resource_group_name = var.resource_group_name
  location            = var.location
  server_name         = azurerm_sql_server.sql_server.name
  edition             = var.sql_database_tier
  requested_service_objective_name = "P1" # Premium tier, P1: 125 DTUs
  max_size_gb         = var.sql_database_size_gb
  tags                = var.tags
}

# Backup Retention Policy (if required)
resource "azurerm_backup_policy_vm" "long_term_retention" {
  name                = "${var.sql_server_name}-backup-policy"
  resource_group_name = var.resource_group_name
  location            = var.location
  retention_policy {
    daily_schedule {
      retention_duration = "${var.long_term_retention_backup}GB"
    }
  }
  tags = var.tags
}
