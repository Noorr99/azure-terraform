//
// Resource Group Variables
//
variable "resource_group_name" {
  description = "Specifies the name of the resource group."
  type        = string
  default     = "rg-nih-dev-001"
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
    environment = "dev"
    project     = "nih"
  }
}

//
// Virtual Network (VNet) Variables
//
// Microsoft recommends: vnet-<subscription purpose or project>-<region>-<###>
variable "aks_vnet_name" {
  description = "Specifies the name of the Azure virtual network."
  type        = string
  default     = "vnet-nih-dev-001"
}

variable "aks_vnet_address_space" {
  description = "Specifies the address space for the Azure virtual network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

//
// Subnet Variables for VMs and Private Endpoints
//
// Microsoft recommends: snet-<purpose>-<region>-<###>
variable "vm_subnet_name" {
  description = "Specifies the name of the subnet for virtual machines."
  type        = string
  default     = "snet-nih-dev-vm-001"
}

variable "vm_subnet_address_prefix" {
  description = "Specifies the address prefix for the VM subnet."
  type        = list(string)
  default     = ["10.0.48.0/20"]
}

variable "pe_subnet_name" {
  description = "Specifies the name of the subnet for private endpoints."
  type        = string
  default     = "snet-nih-dev-pe-001"
}

variable "pe_subnet_address_prefix" {
  description = "Specifies the address prefix for the private endpoint subnet."
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

//
// Virtual Machine (VM) Variables
//
// Typically: vm-<project>-<environment>-<###>
//
// 1) vm_name: for the Azure resource name (can be more descriptive, up to 64 chars).
// 2) vm_computer_name: for the Windows "computer_name" (MUST be <= 15 chars).
//
variable "vm_name" {
  description = "Specifies the Azure resource name of the virtual machine."
  type        = string
  default     = "vm-nih-dev-001"
}

variable "vm_computer_name" {
  description = "Specifies the Windows computer name (NetBIOS name) for the VM (<= 15 chars)."
  type        = string
  default     = "vm-nih-dev-01"
}

variable "vm_count" {
  description = "The number of virtual machines to create."
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "Specifies the size of the virtual machine."
  type        = string
  default     = "Standard_DS1_v2"
}

variable "vm_public_ip" {
  description = "Specifies whether to create a public IP for the virtual machine."
  type        = bool
  default     = false
}

variable "admin_username" {
  description = "Specifies the admin username for the virtual machine."
  type        = string
  default     = "azadmin"
}

variable "admin_password" {
  description = "Specifies the administrator password for the Windows virtual machine."
  type        = string
  sensitive   = true
}

variable "vm_os_disk_image" {
  description = "Specifies the OS disk image for the virtual machine."
  type        = map(string)
  default     = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

//
// DNS Label
//
// Example: <label>.<region>.cloudapp.azure.com
variable "domain_name_label" {
  description = "Specifies the domain name label for the virtual machine."
  type        = string
  default     = "nih-dev-001"
}

variable "vm_os_disk_storage_account_type" {
  description = "Specifies the storage account type for the OS disk of the virtual machine."
  type        = string
  default     = "Premium_LRS"

  validation {
    condition = contains(
      [
        "Premium_LRS",
        "Premium_ZRS",
        "StandardSSD_LRS",
        "StandardSSD_ZRS",
        "Standard_LRS"
      ],
      var.vm_os_disk_storage_account_type
    )
    error_message = "The storage account type for the OS disk is invalid. Valid options are Premium_LRS, Premium_ZRS, StandardSSD_LRS, StandardSSD_ZRS, Standard_LRS."
  }
}

//
// Key Vault Variables
//
// Example prefix: kv-<project>-<environment>-<###>
variable "key_vault_name" {
  description = "Specifies the name of the Key Vault."
  type        = string
  default     = "kv-nih-dev-001"
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
// ACR Variables
//
// Example: cr<project><environment><###>
variable "acr_name" {
  description = "Specifies the name of the Container Registry."
  type        = string
  default     = "crnihdev001"
}

variable "acr_admin_enabled" {
  description = "Specifies whether the ACR admin user is enabled."
  type        = bool
  default     = false
}

variable "acr_sku" {
  description = "The SKU of the Container Registry. Possible values are 'Basic', 'Standard', or 'Premium'."
  type        = string
  default     = "Premium"
}

variable "acr_georeplication_locations" {
  description = "A list of Azure locations where the container registry should be geo-replicated."
  type        = list(string)
  default     = []
}

//
// Databricks Workspace Variables
//
// Example: dbw-<project>-<environment>-<###>
variable "workspace_name" {
  description = "Name of Databricks workspace"
  type        = string
  default     = "dbw-nih-dev-001"
}

variable "databricks_vnet_resource_group_name" {
  description = "Name of the resource group containing the virtual network for Databricks"
  type        = string
  default     = "rg-nih-dev-001"
}

variable "databricks_private_subnet_name" {
  description = "Name of the private subnet for Databricks"
  type        = string
  default     = "snet-nih-dev-dbp-001"
}

variable "databricks_public_subnet_name" {
  description = "Name of the public subnet for Databricks"
  type        = string
  default     = "snet-nih-dev-dbu-001"
}

// Security Group Variables for Databricks
// For NSGs, Microsoft recommends: nsg-<policy or app name>-<###>
variable "databricks_security_group_prefix" {
  description = "Prefix for the names of the security groups created by the Databricks module"
  type        = string
  default     = "nsg-dbr-nih-dev"
}

// Tags for Databricks Resources
variable "databricks_tags" {
  description = "Tags to apply to Databricks resources"
  type        = map(string)
  default     = {
    environment = "dev"
    team        = "data-engineering"
    project     = "nih"
  }
}

//
// Datalake storage variables
//
// For Data Lake Storage, recommended: dls<project><environment>
variable "datalake_storage_account_name" {
  description = "The name of the Data Lake Storage account"
  type        = string
  default     = "dlsnihdev"
}

variable "datalake_account_tier" {
  description = "The tier of the Data Lake Storage account"
  type        = string
  default     = "Standard"
}

variable "datalake_account_replication_type" {
  description = "The replication type of the Data Lake Storage account"
  type        = string
  default     = "LRS"
}

variable "datalake_account_kind" {
  description = "The kind of the Data Lake Storage account"
  type        = string
  default     = "StorageV2"
}

variable "datalake_is_hns_enabled" {
  description = "Whether the hierarchical namespace is enabled"
  type        = bool
  default     = true
}

// Filesystem naming can be an internal preference. Keep it short, e.g., fs<project><environment>.
variable "datalake_filesystem_name" {
  description = "The name of the Data Lake Storage Gen2 filesystem"
  type        = string
  default     = "fsnihdev"
}

variable "datalake_filesystem_properties" {
  description = "The properties of the Data Lake Storage Gen2 filesystem"
  type        = map(string)
  default     = {
    hello = "aGVsbG8="
  }
}
