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
variable "dtm_vnet_name" {
  description = "Specifies the name of the Azure virtual network."
  type        = string
}

variable "dtm_vnet_address_space" {
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

variable "data_subnet_name" {
  description = "Specifies the name of the subnet for sql database."
  type        = string
}

variable "data_subnet_address_prefix" {
  description = "Specifies the address prefix for sql database."
  type        = list(string)
}


/*
variable "vm_names" {
  type = map(string)
  default = {
    "vm0"    = "vm-dtm-dev-fe-01"
  }
}
*/

variable "vm_name" {
  description = "(Required) Specifies the name of the virtual machine"
  type        = string
}

variable "vm_size" {
  description = "Specifies the size of the Windows virtual machine."
  type        = string
}
/*
variable "vm_count" {
  description = "The number of Windows virtual machines to create."
  type        = number
}
*/


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

variable "data_disk_name" {
  description = "The name of the additional data disk."
  type        = string
}

variable "data_disk_caching" {
  description = "Caching option for the data disk. Valid values: 'None', 'ReadOnly', or 'ReadWrite'."
  type        = string
  default     = "None"  # You can change this default as needed.
}

variable "data_disk_create_option" {
  description = "Specifies how the data disk should be created. Valid values: 'Attach', 'FromImage', or 'Empty'."
  type        = string
  default     = "Empty"
}

variable "data_disk_size_gb" {
  description = "Specifies the size of the additional data disk in gigabytes."
  type        = number
  default     = 128  # Adjust this as needed.
}

variable "data_disk_lun" {
  description = "Specifies the Logical Unit Number (LUN) for the data disk. Must be unique among all disks on the VM."
  type        = number
}

variable "data_disk_write_accelerator_enabled" {
  description = "Specifies if write accelerator is enabled on the disk. (Only applicable on Premium_LRS with no caching and M-Series VMs)"
  type        = bool
  default     = false
}

variable "data_disk_managed_disk_type" {
  description = "Specifies the type of managed disk to create. Valid values include: 'Standard_LRS', 'StandardSSD_LRS', 'Premium_LRS', or 'UltraSSD_LRS'."
  type        = string
  default     = "StandardSSD_LRS"
}


/*
variable "zone" {
  description = "Specifies the availability zones of the default node pool"
  default     = ["2", "3"]
  type        = list(string)
}
*/
variable "os_disk_size_gb" {
  type        = number
  default     = 20
  description = "Specifies the size (in gigabytes) of the OS disk for the virtual machine."
}

////////////////////////////////////////////////////////////////////////
// SQL Database Variables
////////////////////////////////////////////////////////////////////////
variable "sql_server_name" {
  description = "Specifies the name of the SQL Server."
  type        = string
}

variable "sql_admin_username" {
  description = "Specifies the admin username for the SQL Server."
  type        = string
}

variable "sql_admin_password" {
  description = "Specifies the admin password for the SQL Server."
  type        = string
  sensitive   = true
}

variable "sql_database_name" {
  description = "Specifies the name of the SQL Database."
  type        = string
}

variable "sql_database_dtu" {
  description = "Specifies the DTU allocation for the SQL Database."
  type        = string
}

variable "sql_database_tier" {
  description = "Specifies the pricing tier for the SQL Database."
  type        = string
}

variable "sql_database_size_gb" {
  description = "Specifies the maximum storage size for the SQL Database in GB."
  type        = number
}

variable "long_term_retention_backup" {
  description = "Specifies the size of the long-term retention backup in GB."
  type        = number
}

variable "geo_backup_enabled" {
  description = "Specifies whether geo-backup is enabled."
  type        = bool
}

variable "storage_account_type" {
  description = "Specifies the type of storage account used."
  type        = string
}


variable "sku_name" {
  description = "Specifies the sku name."
  type        = string
}

variable "zone_redundant" {
  description = "Specifies whether zone redundancy is enabled."
  type        = bool
}

////////////////////////////////////////////////////////////////////////
// Cognitive Service Variables
////////////////////////////////////////////////////////////////////////
variable "cognitive_service_name" {
  description = "Specifies the name of the Azure Cognitive Service."
  type        = string
}

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

variable "cognitive_service_identity_type" {
  type        = string
  description = "The managed identity type: 'SystemAssigned', 'UserAssigned' or 'SystemAssigned,UserAssigned'."
  default     = "SystemAssigned"
}