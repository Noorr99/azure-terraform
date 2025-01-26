//
// Resource Group Variables
//
variable "resource_group_name" {
  description = "Specifies the name of the resource group."
  type        = string
  default     = "rg-nih-dev-002"
}

variable "location" {
  description = "Specifies the Azure region where resources will be created."
  type        = string
  default     = "northeurope"
}

variable "tags" {
  description = "Specifies tags to apply to all resources."
  type        = map(string)
  default     = {
    createdWith = "Terraform"
  }
}

//
// Virtual Network (VNet) Variables
//
variable "aks_vnet_name" {
  description = "Specifies the name of the Azure virtual network."
  type        = string
  default     = "vnet-dev-qatar-002"
}

variable "aks_vnet_address_space" {
  description = "Specifies the address space for the Azure virtual network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "shared_subnet_name" {
  description = "The name of the shared subnet for SQL Database, Key Vault, and Data Lake."
  type        = string
  default     = "snet-shared-qatar-002"
}

variable "shared_subnet_address_prefix" {
  description = "The address prefix for the shared subnet."
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

//
// Key Vault Variables
//
variable "key_vault_name" {
  description = "Specifies the name of the Key Vault."
  type        = string
  default     = "kv-nih-shared-dev-02"
}

variable "tenant_id" {
  description = "Specifies the tenant ID for the Key Vault."
  type        = string
}

variable "key_vault_sku" {
  description = "Specifies the SKU of the Key Vault. Possible values are 'standard' or 'premium'."
  type        = string
  default     = "standard"
}

variable "key_vault_enabled_for_deployment" {
  description = "Allows Azure VMs to retrieve certificates stored as secrets."
  type        = bool
  default     = false
}

variable "key_vault_enabled_for_disk_encryption" {
  description = "Allows Azure Disk Encryption to retrieve secrets and unwrap keys."
  type        = bool
  default     = false
}

variable "key_vault_enabled_for_template_deployment" {
  description = "Allows Azure Resource Manager to retrieve secrets from the key vault."
  type        = bool
  default     = false
}

variable "key_vault_enable_rbac_authorization" {
  description = "Specifies whether Key Vault uses RBAC for authorization."
  type        = bool
  default     = false
}

variable "key_vault_purge_protection_enabled" {
  description = "Specifies if purge protection is enabled on the Key Vault."
  type        = bool
  default     = false
}

variable "key_vault_soft_delete_retention_days" {
  description = "Specifies the soft-delete retention days for the Key Vault."
  type        = number
  default     = 30
}

variable "key_vault_bypass" {
  description = "Specifies which traffic can bypass network rules for Key Vault. Options: 'AzureServices' or 'None'."
  type        = string
  default     = "AzureServices"
}

variable "key_vault_default_action" {
  description = "Specifies the default action for network rules on Key Vault. Options: 'Allow' or 'Deny'."
  type        = string
  default     = "Allow"
}

variable "key_vault_ip_rules" {
  description = "List of IP addresses/CIDR blocks allowed to access the Key Vault."
  type        = list(string)
  default     = []
}

//
// Data Lake Storage Variables
//
variable "datalake_storage_account_name" {
  description = "The name of the Data Lake Storage account."
  type        = string
  default     = "dlsnihdev02"
}

variable "datalake_account_tier" {
  description = "The tier of the Data Lake Storage account."
  type        = string
  default     = "Standard"
}

variable "datalake_account_replication_type" {
  description = "The replication type of the Data Lake Storage account."
  type        = string
  default     = "LRS"
}

variable "datalake_account_kind" {
  description = "The kind of the Data Lake Storage account."
  type        = string
  default     = "StorageV2"
}

variable "datalake_is_hns_enabled" {
  description = "Specifies whether hierarchical namespace is enabled for the Data Lake."
  type        = bool
  default     = true
}

//
// SQL Database Variables
//
variable "sql_server_name" {
  description = "Specifies the name of the SQL Server."
  type        = string
  default     = "sql-server-dev-nih"
}

variable "sql_admin_username" {
  description = "Specifies the admin username for the SQL Server."
  type        = string
  default     = "sqladmin"
}

variable "sql_admin_password" {
  description = "Specifies the admin password for the SQL Server."
  type        = string
  sensitive   = true
}

variable "sql_database_name" {
  description = "Specifies the name of the SQL Database."
  type        = string
  default     = "sql-db-dev"
}

variable "sql_database_dtu" {
  description = "Specifies the DTU allocation for the SQL Database."
  type        = string
  default     = "125"
}

variable "sql_database_tier" {
  description = "Specifies the pricing tier for the SQL Database."
  type        = string
  default     = "Premium"
}

variable "sql_database_size_gb" {
  description = "Specifies the maximum storage size for the SQL Database in GB."
  type        = number
  default     = 500
}

variable "long_term_retention_backup" {
  description = "Specifies the size of the long-term retention backup in GB."
  type        = number
  default     = 100
}

variable "public_network_access_enabled" { 
  description = "(Optional) Whether public network access is allowed for this Key Vault."
  default     = false
}