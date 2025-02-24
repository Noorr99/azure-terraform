////////////////////////////////////////////////////////////////////////
// Existing Variables (Resource Group, Location, Tags)
////////////////////////////////////////////////////////////////////////
variable "resource_group_name" {
  description = "Specifies the name of the resource group."
  type        = string
}

variable "location" {
  description = "Specifies the Azure region where resources will be created."
  type        = string
}

variable "tags" {
  description = "Specifies tags to apply to all resources."
  type        = map(string)
}

////////////////////////////////////////////////////////////////////////
// Virtual Network (VNet) Variables
////////////////////////////////////////////////////////////////////////
variable "vnet_name" {
  description = "Specifies the name of the Azure Virtual Network."
  type        = string
}

variable "vnet_address_space" {
  description = "Specifies the address space for the Azure Virtual Network."
  type        = list(string)
}

variable "shared_subnet_name" {
  description = "The name of the shared subnet for SQL Database, Key Vault, and Data Lake."
  type        = string
}

variable "shared_subnet_address_prefix" {
  description = "The address prefix for the shared subnet."
  type        = list(string)
}

////////////////////////////////////////////////////////////////////////
// Secondary Subnet Variables
////////////////////////////////////////////////////////////////////////
variable "secondary_subnet_name" {
  description = "Specifies the name of the secondary subnet."
  type        = string
}

variable "secondary_subnet_address_prefix" {
  description = "Specifies the address prefix for the secondary subnet."
  type        = list(string)
}

////////////////////////////////////////////////////////////////////////
// Key Vault Variables
////////////////////////////////////////////////////////////////////////
variable "key_vault_name" {
  description = "Specifies the name of the Key Vault."
  type        = string
}

variable "tenant_id" {
  description = "Specifies the tenant ID for the Key Vault and other services."
  type        = string
  sensitive   = true
}

variable "key_vault_sku" {
  description = "Specifies the SKU of the Key Vault. Possible values are 'standard' or 'premium'."
  type        = string
}

variable "key_vault_enabled_for_deployment" {
  description = "Allows Azure VMs to retrieve certificates stored as secrets."
  type        = bool
}

variable "key_vault_enabled_for_disk_encryption" {
  description = "Allows Azure Disk Encryption to retrieve secrets and unwrap keys."
  type        = bool
}

variable "key_vault_enabled_for_template_deployment" {
  description = "Allows Azure Resource Manager to retrieve secrets from the key vault."
  type        = bool
}

variable "key_vault_enable_rbac_authorization" {
  description = "Specifies whether Key Vault uses RBAC for authorization."
  type        = bool
}

variable "key_vault_purge_protection_enabled" {
  description = "Specifies if purge protection is enabled on the Key Vault."
  type        = bool
}

variable "key_vault_soft_delete_retention_days" {
  description = "Specifies the soft-delete retention days for the Key Vault."
  type        = number
}

variable "key_vault_bypass" {
  description = "Specifies which traffic can bypass network rules for Key Vault. Options: 'AzureServices' or 'None'."
  type        = string
}

variable "key_vault_default_action" {
  description = "Specifies the default action for network rules on Key Vault. Options: 'Allow' or 'Deny'."
  type        = string
}

variable "key_vault_ip_rules" {
  description = "List of IP addresses/CIDR blocks allowed to access the Key Vault."
  type        = list(string)
}

////////////////////////////////////////////////////////////////////////
// Data Factory Variables
////////////////////////////////////////////////////////////////////////
variable "data_factory_name" {
  description = "Specifies the name of the Azure Data Factory."
  type        = string
}

variable "public_network_enabled" {
  description = "Specifies whether the Data Factory is visible to the public network."
  type        = bool
}

variable "data_factory_identity_type" {
  description = "Specifies the identity type for the Data Factory. Valid values include 'SystemAssigned', 'UserAssigned' or 'SystemAssigned, UserAssigned'."
  type        = string
}

////////////////////////////////////////////////////////////////////////
// Cognitive Service Variables
////////////////////////////////////////////////////////////////////////

variable "cognitive_service_kind" {
  description = "Specifies the kind of the Cognitive Service. For a multi-service Azure AI resource (including Custom Vision), use 'CognitiveServices'."
  type        = string
}

variable "cognitive_service_sku" {
  description = "Specifies the SKU of the Cognitive Service. For the Standard tier of Custom Vision, use 'S0'."
  type        = string
}

variable "cognitive_public_network_access_enabled" {
  description = "Specifies if the Cognitive Service has public network access enabled."
  type        = bool
}

variable "cognitive_custom_subdomain_name" {
  description = "Custom subdomain name for the Cognitive Service account (required for private endpoint connectivity). Must be unique within the region."
  type        = string
}



////////////////////////////////////////////////////////////////////////
// Log Analytics Workspace (Optional)
////////////////////////////////////////////////////////////////////////
variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace (if any)."
  type        = string
}
