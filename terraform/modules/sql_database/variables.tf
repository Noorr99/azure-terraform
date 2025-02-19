variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "location" {
  description = "The Azure location."
  type        = string
}

variable "sql_server_name" {
  description = "The name of the SQL Server."
  type        = string
}

variable "sql_admin_username" {
  description = "The admin username for the SQL Server."
  type        = string
}

variable "sql_admin_password" {
  description = "The admin password for the SQL Server."
  type        = string
}

variable "sql_database_name" {
  description = "The name of the SQL Database."
  type        = string
}

variable "sql_database_tier" {
  description = "The pricing tier for the SQL Database."
  type        = string
}

variable "sql_database_dtu" {
  description = "The DTU allocation for the SQL Database."
  type        = string
}

variable "sql_database_size_gb" {
  description = "The maximum storage size for the SQL Database."
  type        = number
}

variable "subnet_id" {
  description = "The ID of the subnet for the private endpoint."
  type        = string
}

variable "private_dns_zone_id" {
  description = "The ID of the private DNS zone."
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
}

variable "long_term_retention_backup" {
  description = "Specifies the size of the long-term retention backup in GB."
  type        = number
}

variable "geo_backup_enabled" {
  description = "Specifies the size of the geo_backup_enabled "
  type        = bool
}

variable "storage_account_type" {
  description = "Specifies the size of the storage_account_type."
  type        = string
}

/*
variable "sku_name" {
  description = "Specifies the sku_name"
  type        = string
}
*/
variable "zone_redundant" {
  description = "Specifies the zone_redundant"
  type        = bool
}