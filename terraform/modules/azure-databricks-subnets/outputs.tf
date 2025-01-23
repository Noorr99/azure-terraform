output "private_subnet_name" {
  value       = azurerm_subnet.private-subnet.name
  description = "Name of the Databricks private subnet"
}

output "private_subnet_id" {
  value       = azurerm_subnet.private-subnet.id
  description = "ID of the Databricks private subnet"
}

output "private_subnet_prefixes" {
  value       = azurerm_subnet.private-subnet.address_prefixes
  description = "Address space of the Databricks private subnet"
}

output "public_subnet_name" {
  value       = azurerm_subnet.public-subnet.name
  description = "Name of the Databricks public subnet"
}

output "public_subnet_id" {
  value       = azurerm_subnet.public-subnet.id
  description = "ID of the Databricks public subnet"
}

output "public_subnet_prefixes" {
  value       = azurerm_subnet.public-subnet.address_prefixes
  description = "Address space of the Databricks public subnet"
}
