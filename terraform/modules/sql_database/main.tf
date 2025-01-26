#
# azurerm_mssql_server replaces azurerm_sql_server
#
resource "azurerm_mssql_server" "sql_server" {
  name                         = var.sql_server_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password

  # Disable public network access by default
  public_network_access_enabled = false

  tags = var.tags
}

#
# azurerm_mssql_database
#
resource "azurerm_mssql_database" "sql_database" {
  name       = var.sql_database_name
  server_id  = azurerm_mssql_server.sql_server.id
  sku_name   = "P1" # Premium, P1: 125 DTUs equivalent
  max_size_gb = var.sql_database_size_gb
  zone_redundant = false  # set to true if your region supports zone redundancy

  # Additional properties as needed:
  # collation      = "SQL_Latin1_General_CP1_CI_AS"
  # license_type   = "LicenseIncluded"
  # read_scale     = false

  tags = var.tags
}


#
# Private Endpoint
#
resource "azurerm_private_endpoint" "sql_private_endpoint" {
  name                = "${var.sql_server_name}-pe"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "sqlServerConnection"
    private_connection_resource_id = azurerm_mssql_server.sql_server.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  tags = var.tags
}
