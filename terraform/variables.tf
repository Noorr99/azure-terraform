////////////////////////////////////////////////////////////////////////
//                       Global Project & Environment
////////////////////////////////////////////////////////////////////////
# If you no longer need to pass in project/environment, you can remove these.
# Shown here in case you want to keep them for tagging or documentation.
variable "project" {
  type        = string
  description = "Project/Workload code."
  default     = "nih"
}

variable "environment" {
  type        = string
  description = "Environment (e.g. dev, prod)."
  default     = "dev"
}

////////////////////////////////////////////////////////////////////////
//                          Backend Vars
////////////////////////////////////////////////////////////////////////
variable "azure_provider_version" {
  type        = string
  description = "Version of the azurerm provider."
  default     = "3.50"
}

variable "backend_resource_group_name" {
  type        = string
  description = "Resource group used to store the Terraform state."
  default     = "my-tfstate-rg"
}

variable "backend_storage_account_name" {
  type        = string
  description = "Storage account name used to store the Terraform state."
  default     = "mytfstateaccount"
}

variable "backend_container_name" {
  type        = string
  description = "Container name for the Terraform state file."
  default     = "tfstate"
}

variable "backend_key" {
  type        = string
  description = "Key (file name) for where the Terraform state will be saved."
  default     = "terraform.tfstate"
}

////////////////////////////////////////////////////////////////////////
//                       Global Resource Vars
////////////////////////////////////////////////////////////////////////
variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
  # CAF pattern => rg-<project>-<env>
  default     = "rg-nih-dev"
}

variable "location" {
  type        = string
  description = "Azure region for resource deployment."
  default     = "northeurope"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all resources."
  default = {
    createdWith = "Terraform"
  }
}

////////////////////////////////////////////////////////////////////////
//                       VNet & Subnet Vars
////////////////////////////////////////////////////////////////////////
variable "vnet_name" {
  type        = string
  description = "Name of the Azure virtual network."
  # CAF pattern => vnet-<project>-<env>
  default     = "vnet-nih-dev"
}

variable "vnet_address_space" {
  type        = list(string)
  description = "Address space for the Azure virtual network."
  default     = ["10.0.0.0/16"]
}

variable "vm_subnet_name" {
  type        = string
  description = "Name of the subnet for virtual machines."
  # CAF pattern => snet-<project>-<env>-vm
  default     = "snet-nih-dev-vm"
}

variable "vm_subnet_address_prefix" {
  type        = list(string)
  description = "Address prefix for the VM subnet."
  default     = ["10.0.48.0/20"]
}

# Single Private Endpoint Subnet (Key Vault, ACR, Data Lake, etc.)
variable "pe_subnet_name" {
  type        = string
  description = "Name of the subnet for all private endpoints."
  # CAF pattern => snet-<project>-<env>-pe
  default     = "snet-nih-dev-pe"
}

variable "pe_subnet_address_prefix" {
  type        = list(string)
  description = "Address prefix for the private endpoint subnet."
  default     = ["10.0.50.0/24"]
}

////////////////////////////////////////////////////////////////////////
//                       Virtual Machine Vars
////////////////////////////////////////////////////////////////////////
variable "vm_name_prefix" {
  type        = string
  description = "Base prefix for virtual machines."
  # CAF pattern => vm-<project>-<env>
  default     = "vm-nih-dev"
}

variable "vm_count" {
  type        = number
  description = "Number of virtual machines to create."
  default     = 2
}

variable "vm_size" {
  type        = string
  description = "Size of the virtual machine."
  default     = "Standard_DS1_v2"
}

variable "vm_public_ip" {
  type        = bool
  description = "Whether to create a public IP for the VM."
  default     = false
}

variable "admin_username" {
  type        = string
  description = "Admin username for the virtual machines."
  default     = "azadmin"
}

variable "admin_password" {
  type        = string
  description = "Admin password for the virtual machines."
  sensitive   = true
  default     = ""
}

variable "vm_os_disk_image" {
  type        = map(string)
  description = "OS disk image for the virtual machines."
  default = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

variable "domain_name_label" {
  type        = string
  description = "Domain name label for the VMs (for public IP DNS)."
  default     = "windowsnpcvmtrial"
}

variable "vm_os_disk_storage_account_type" {
  type        = string
  description = "Storage account type for the VM OS disk."
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
    error_message = "Invalid OS disk storage account type."
  }
}

////////////////////////////////////////////////////////////////////////
//                          Key Vault Vars
////////////////////////////////////////////////////////////////////////
variable "key_vault_name" {
  type        = string
  description = "Name of the Key Vault."
  # CAF pattern => kv-<project>-<env>
  default     = "kv-nih-dev"
}

variable "tenant_id" {
  type        = string
  description = "Tenant ID for the Key Vault."
}

variable "key_vault_sku" {
  type        = string
  description = "SKU of Key Vault: 'standard' or 'premium'."
  default     = "standard"
}

variable "key_vault_enabled_for_deployment" {
  type        = bool
  description = "Allow Azure VMs to retrieve certificates stored as secrets."
  default     = false
}

variable "key_vault_enabled_for_disk_encryption" {
  type        = bool
  description = "Allow Azure Disk Encryption to retrieve secrets and unwrap keys."
  default     = false
}

variable "key_vault_enabled_for_template_deployment" {
  type        = bool
  description = "Allow ARM templates to retrieve secrets from the Key Vault."
  default     = false
}

variable "key_vault_enable_rbac_authorization" {
  type        = bool
  description = "Use RBAC for authorization in the Key Vault."
  default     = false
}

variable "key_vault_purge_protection_enabled" {
  type        = bool
  description = "Enable purge protection on the Key Vault."
  default     = false
}

variable "key_vault_soft_delete_retention_days" {
  type        = number
  description = "Soft-delete retention days for the Key Vault."
  default     = 30
}

variable "key_vault_bypass" {
  type        = string
  description = "Traffic that can bypass Key Vault network rules. 'AzureServices' or 'None'."
  default     = "None"
}

variable "key_vault_default_action" {
  type        = string
  description = "Default network rule action. 'Allow' or 'Deny'."
  default     = "Deny"
}

variable "key_vault_ip_rules" {
  type        = list(string)
  description = "IP addresses/CIDR blocks allowed to access Key Vault."
  default     = []
}

////////////////////////////////////////////////////////////////////////
//                             ACR Vars
////////////////////////////////////////////////////////////////////////
variable "acr_name" {
  type        = string
  description = <<EOT
Name of the Container Registry.
Per Azure naming constraints, use only lowercase, up to 50 chars.
CAF example => acr<project><env>
EOT
  default = "acrnihdev"
}

variable "acr_admin_enabled" {
  type        = bool
  description = "Enable the admin user on ACR?"
  default     = false
}

variable "acr_sku" {
  type        = string
  description = "SKU of ACR: 'Basic', 'Standard', or 'Premium'."
  default     = "Premium"
}

variable "acr_georeplication_locations" {
  type        = list(string)
  description = "Azure regions for geo-replication of the ACR."
  default     = []
}

////////////////////////////////////////////////////////////////////////
//                          Databricks Vars
////////////////////////////////////////////////////////////////////////
variable "workspace_name" {
  type        = string
  description = "Name of the Databricks workspace."
  default     = "databricksworkspace-nih-dev"
}

variable "databricks_vnet_resource_group_name" {
  type        = string
  description = "Resource group containing the VNet used by Databricks."
  default     = "VMVNet"
}

variable "databricks_private_subnet_address_prefixes" {
  type        = list(string)
  description = "Address prefixes for the Databricks private subnet."
  default     = ["10.0.2.0/24"]
}

variable "databricks_public_subnet_address_prefixes" {
  type        = list(string)
  description = "Address prefixes for the Databricks public subnet."
  default     = ["10.0.3.0/24"]
}

variable "databricks_service_delegation_actions" {
  type        = list(string)
  description = "Service delegation actions for Databricks subnets."
  default = [
    "Microsoft.Network/virtualNetworks/subnets/join/action",
    "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
    "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
  ]
}

variable "databricks_additional_service_endpoints" {
  type        = list(string)
  description = "Additional service endpoints for Databricks subnets."
  default     = ["Microsoft.Storage"]
}

variable "databricks_security_group_prefix" {
  type        = string
  description = "Prefix for the Databricks security group names."
  default     = "databricks-sg"
}

variable "databricks_tags" {
  type        = map(string)
  description = "Tags applied to Databricks resources."
  default = {
    environment = "production"
    team        = "data-engineering"
  }
}

////////////////////////////////////////////////////////////////////////
//                          Data Lake Vars
////////////////////////////////////////////////////////////////////////
variable "datalake_storage_account_name" {
  type        = string
  description = <<EOT
Name of the Data Lake Storage account.
Must be unique, 3-24 chars, all lowercase.
CAF pattern => st<project><env>
EOT
  default     = "stnihdev"
}

variable "datalake_account_tier" {
  type        = string
  description = "Tier of the Data Lake Storage account."
  default     = "Standard"
}

variable "datalake_account_replication_type" {
  type        = string
  description = "Replication type: LRS, GRS, RAGRS, ZRS, etc."
  default     = "LRS"
}

variable "datalake_account_kind" {
  type        = string
  description = "Kind of the Data Lake Storage account."
  default     = "StorageV2"
}

variable "datalake_is_hns_enabled" {
  type        = bool
  description = "Enable hierarchical namespace?"
  default     = true
}

variable "datalake_filesystem_name" {
  type        = string
  description = "Name of the Data Lake Storage Gen2 filesystem."
  default     = "datalakefsnpctest"
}

variable "datalake_filesystem_properties" {
  type        = map(string)
  description = "Properties for the Data Lake Storage Gen2 filesystem."
  default = {
    hello = "aGVsbG8="
  }
}
