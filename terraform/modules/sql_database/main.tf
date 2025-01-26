resource "azurerm_sql_server" "sql_server" {
  name                         = var.sql_server_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password
  tags                         = var.tags
}

resource "azurerm_sql_database" "sql_database" {
  name                = var.sql_database_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_sql_server.sql_server.name
  location            = var.location
  edition             = var.sql_database_tier
  requested_service_objective_name = "P1"
  max_size_gb         = var.sql_database_size_gb
  zone_redundant      = true
  tags                = var.tags
}

resource "azurerm_private_endpoint" "sql_private_endpoint" {
  name                = "${var.sql_server_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "sqlServerConnection"
    private_connection_resource_id = azurerm_sql_server.sql_server.id
    subresource_names              = ["sqlServer"]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql_dns_vnet_link" {
  name                  = "${var.sql_server_name}-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_id   = var.private_dns_zone_id
  virtual_network_id    = var.subnet_id
  registration_enabled  = false
}
