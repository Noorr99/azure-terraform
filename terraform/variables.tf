//
// Resource Group Variables
//
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

//
// Virtual Network (VNet) Variables
//
variable "aks_vnet_name" {
  description = "Specifies the name of the Azure virtual network."
  type        = string
}

variable "aks_vnet_address_space" {
  description = "Specifies the address space for the Azure virtual network."
  type        = list(string)
}

//
// Subnet Variables for VMs and Private Endpoints
//
variable "vm_subnet_name" {
  description = "Specifies the name of the subnet for virtual machines."
  type        = string
}

variable "vm_subnet_address_prefix" {
  description = "Specifies the address prefix for the VM subnet."
  type        = list(string)
}

variable "pe_subnet_name" {
  description = "Specifies the name of the subnet for private endpoints."
  type        = string
}

variable "pe_subnet_address_prefix" {
  description = "Specifies the address prefix for the private endpoint subnet."
  type        = list(string)
}

//
// Virtual Machine (VM) Variables (Windows)
//
/*
variable "vm_name" {
  description = "Specifies the base name of the Windows virtual machine."
  type        = string
}


variable "vm_names" {
  description = "List of specific names for the VMs"
  type        = list(string)
  default     = ["vm-name-1", "vm-name-2", "vm-name-3"]
}

variable "availability_set_name" {
  type        = string
  description = "The full name of the Availability Set. (e.g., 'myorg-web-prod-qat-as-01')"
}
*/

variable "vm_names" {
  type = map(string)
  default = {
    "vm0"    = "sr-prod-shir-01"
    "vm1"    = "sr-prod-jb-informatica-01"
    "vm3"    = "sr-prod-pbi-gw-01"
  }
}
/*
variable "vm_count" {
  description = "The number of Windows virtual machines to create."
  type        = number
}
*/
variable "vm_size" {
  description = "Specifies the size of the Windows virtual machine."
  type        = string
}

variable "vm_public_ip" {
  description = "Specifies whether to create a public IP for the Windows virtual machine."
  type        = bool
}

variable "admin_username" {
  description = "Specifies the admin username for the Windows virtual machine."
  type        = string
}

variable "admin_password" {
  description = "Specifies the administrator password for the Windows virtual machine."
  type        = string
  sensitive   = true
}

variable "vm_os_disk_image" {
  description = "Specifies the OS disk image for the Windows virtual machine."
  type        = map(string)
}

variable "domain_name_label" {
  description = "Specifies the domain name label for the Windows virtual machine."
  type        = string
}

variable "vm_os_disk_storage_account_type" {
  description = "Specifies the storage account type for the OS disk of the Windows virtual machine."
  type        = string

  validation {
    condition     = contains(
      ["Premium_LRS", "Premium_ZRS", "StandardSSD_LRS", "StandardSSD_ZRS", "Standard_LRS"],
      var.vm_os_disk_storage_account_type
    )
    error_message = "The storage account type for the OS disk is invalid. Valid options are Premium_LRS, Premium_ZRS, StandardSSD_LRS, StandardSSD_ZRS, Standard_LRS."
  }
}

/*
variable "zones" {
  description = "The Availability Zone where the VM should be created. Valid values are 1, 2, or 3."
  type        = number
  default     = 3
  
  validation {
    condition     = contains([1, 2, 3], var.zone)
    error_message = "Zone must be 1, 2, or 3."
  }
}
*/

variable "zone" {
  description = "Specifies the availability zones of the default node pool"
  default     = ["2", "3"]
  type        = list(string)
}
//
// Key Vault Variables
//
variable "key_vault_name" {
  description = "Specifies the name of the Key Vault."
  type        = string
}

variable "tenant_id" {
  description = "Specifies the tenant ID for the Key Vault."
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

variable "public_network_access_enabled" {
  description = "(Optional) Whether public network access is allowed for this Key Vault."
  type        = bool
}

//
// ACR Variables
//
variable "acr_name" {
  description = "Specifies the name of the Container Registry."
  type        = string
}

variable "acr_admin_enabled" {
  description = "Specifies whether the ACR admin user is enabled."
  type        = bool
}

variable "acr_sku" {
  description = "The SKU of the Container Registry. Possible values are 'Basic', 'Standard', or 'Premium'."
  type        = string
}

variable "acr_georeplication_locations" {
  description = "A list of Azure locations where the container registry should be geo-replicated."
  type        = list(string)
}

variable "acr_name_pe" {
  description = "The name of the container registry private endpoint."
  type        = string
}

variable "zone_redundancy_enabled" {
  description = "Enable zone redundancy for ACR"
  type        = bool
  default     = true
}

//
// Databricks Workspace Variables
//
variable "workspace_name" {
  description = "Name of Databricks workspace."
  type        = string
}

variable "databricks_vnet_resource_group_name" {
  description = "Name of the resource group containing the virtual network for Databricks."
  type        = string
}

variable "databricks_private_subnet_name" {
  description = "Name of the private subnet for Databricks."
  type        = string
}

variable "databricks_public_subnet_name" {
  description = "Name of the public subnet for Databricks."
  type        = string
}

variable "public_subnet_address_prefixes" {
  description = "IP address prefixes for the public subnet for Databricks."
  type        = list(string)
}

variable "private_subnet_address_prefixes" {
  description = "IP address prefixes for the private subnet for Databricks."
  type        = list(string)
}

//
// Security Group Variables for Databricks
//
variable "databricks_security_group_prefix" {
  description = "Prefix for the names of the security groups created by the Databricks module."
  type        = string
}

variable "managed_resource_group_name" {
  description = "Name of managed resource group which contains the virtual network."
  type        = string
}

variable "sku_dbw" {
  description = "Specify sku for azure databricks."
  type        = string
}

//
// Datalake Storage Variables
//
variable "datalake_storage_account_name" {
  description = "The name of the Data Lake Storage account."
  type        = string
}

variable "datalake_storage_account_pe" {
  description = "The name of the Data Lake Storage account private endpoint."
  type        = string
}

variable "datalake_account_tier" {
  description = "The tier of the Data Lake Storage account."
  type        = string
}

variable "datalake_account_replication_type" {
  description = "The replication type of the Data Lake Storage account."
  type        = string
}

variable "datalake_account_kind" {
  description = "The kind of the Data Lake Storage account."
  type        = string
}

variable "datalake_is_hns_enabled" {
  description = "Whether the hierarchical namespace is enabled."
  type        = bool
}

variable "datalake_filesystem_name" {
  description = "The name of the Data Lake Storage Gen2 filesystem."
  type        = string
}

variable "datalake_filesystem_properties" {
  description = "The properties of the Data Lake Storage Gen2 filesystem."
  type        = map(string)
}

/*
variable "soft_delete_retention_days" {
  description = "The number of days to retain soft deleted data"
  type        = number
}

variable "enable_versioning" {
  description = "Flag to enable versioning"
  type        = bool
}

variable "enable_change_feed" {
  description = "Flag to enable change feed"
  type        = bool
}
*/

//////////////////////////////////////
// Ubuntu Virtual Machine Variables (Separate from Windows)
//////////////////////////////////////
variable "ubuntu_vm_name" {
  description = "Specifies the base name of the Ubuntu virtual machine."
  type        = string
}

variable "ubuntu_vm_count" {
  description = "The number of Ubuntu virtual machines to create."
  type        = number
  default     = 1
}

variable "ubuntu_vm_size" {
  description = "Specifies the size of the Ubuntu virtual machine."
  type        = string
}

variable "ubuntu_vm_public_ip" {
  description = "Specifies whether to create a public IP for the Ubuntu virtual machine."
  type        = bool
}

variable "ubuntu_admin_username" {
  description = "Specifies the admin username for the Ubuntu virtual machine."
  type        = string
}

variable "ubuntu_admin_password" {
  description = "Specifies the administrator password for the Ubuntu virtual machine."
  type        = string
  sensitive   = true
}

/*
variable "ubuntu_vm_os_disk_image" {
  description = "Specifies the OS disk image for the Ubuntu virtual machine."
  type        = map(string)
  default = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
*/

variable "ubuntu_vm_os_disk_image" {
  description = "Specifies the OS disk image for the Ubuntu virtual machine."
  type        = map(string)
  default = {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "ubuntu-pro"
    version   = "latest"
  }
}
variable "ubuntu_domain_name_label" {
  description = "Specifies the domain name label for the Ubuntu virtual machine."
  type        = string
}

variable "ubuntu_vm_os_disk_storage_account_type" {
  description = "Specifies the storage account type for the OS disk of the Ubuntu virtual machine."
  type        = string
  default     = "StandardSSD_LRS"

  validation {
    condition     = contains(
      ["Premium_LRS", "Premium_ZRS", "StandardSSD_LRS", "StandardSSD_ZRS", "Standard_LRS"],
      var.ubuntu_vm_os_disk_storage_account_type
    )
    error_message = "The storage account type for the Ubuntu OS disk is invalid. Valid options are Premium_LRS, Premium_ZRS, StandardSSD_LRS, StandardSSD_ZRS, Standard_LRS."
  }
}


