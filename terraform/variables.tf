######################
# Log Analytics
######################
variable "log_analytics_workspace_name" {
  description = "Specifies the name of the Log Analytics workspace"
  type        = string
  default     = "BaboAksWorkspace"
}

variable "solution_plan_map" {
  description = "Specifies solutions to deploy to the Log Analytics workspace"
  type        = map(any)
  default     = {
    ContainerInsights = {
      product   = "OMSGallery/ContainerInsights"
      publisher = "Microsoft"
    }
  }
}

######################
# General Settings
######################
variable "location" {
  description = "Specifies the location for the resource group and all resources"
  type        = string
  default     = "northeurope"
}

variable "resource_group_name" {
  description = "Specifies the resource group name"
  type        = string
  default     = "BaboRG"
}

variable "tags" {
  description = "(Optional) Specifies tags for all resources"
  type        = map(string)
  default     = {
    createdWith = "Terraform"
  }
}

######################
# Hub Virtual Network
######################
variable "hub_vnet_name" {
  description = "Specifies the name of the hub virtual network"
  type        = string
  default     = "HubVNet"
}

variable "hub_address_space" {
  description = "Specifies the address space of the hub virtual network"
  type        = list(string)
  default     = ["10.1.0.0/16"]
}

variable "hub_firewall_subnet_address_prefix" {
  description = "Specifies the address prefix of the firewall subnet"
  type        = list(string)
  default     = ["10.1.0.0/24"]
}

variable "hub_bastion_subnet_address_prefix" {
  description = "Specifies the address prefix of the bastion subnet"
  type        = list(string)
  default     = ["10.1.1.0/24"]
}

######################
# AKS (and general workload) Virtual Network
######################
variable "aks_vnet_name" {
  description = "Specifies the name of the virtual network used for workloads"
  type        = string
  default     = "AksVNet"
}

variable "aks_vnet_address_space" {
  description = "Specifies the address space of the virtual network used for workloads"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

######################
# Subnets used in the aks_network module
######################
variable "default_node_pool_subnet_name" {
  description = "Specifies the name of the subnet hosting the default node pool (used by other resources as needed)"
  type        = string
  default     = "SystemSubnet"
}

variable "default_node_pool_subnet_address_prefix" {
  description = "Specifies the address prefix of the subnet that hosts the default node pool"
  type        = list(string)
  default     = ["10.0.0.0/20"]
}

variable "additional_node_pool_subnet_name" {
  description = "Specifies the name of the additional node pool subnet"
  type        = string
  default     = "UserSubnet"
}

variable "additional_node_pool_subnet_address_prefix" {
  description = "Specifies the address prefix of the additional node pool subnet"
  type        = list(string)
  default     = ["10.0.16.0/20"]
}

variable "pod_subnet_name" {
  description = "Specifies the name of the pod subnet"
  type        = string
  default     = "PodSubnet"
}

variable "pod_subnet_address_prefix" {
  description = "Specifies the address prefix of the pod subnet"
  type        = list(string)
  default     = ["10.0.32.0/20"]
}

variable "vm_subnet_name" {
  description = "Specifies the name of the subnet in which the virtual machine will be deployed"
  type        = string
  default     = "VmSubnet"
}

variable "vm_subnet_address_prefix" {
  description = "Specifies the address prefix of the virtual machine subnet"
  type        = list(string)
  default     = ["10.0.48.0/20"]
}

######################
# Virtual Machine Settings
######################
variable "vm_name" {
  description = "Specifies the name of the virtual machine"
  type        = string
  default     = "TestVm"
}

variable "vm_public_ip" {
  description = "(Optional) Specifies whether to create a public IP for the virtual machine"
  type        = bool
  default     = false
}

variable "vm_size" {
  description = "Specifies the size of the virtual machine"
  type        = string
  default     = "Standard_DS1_v2"
}

variable "vm_os_disk_storage_account_type" {
  description = "Specifies the storage account type for the VM's OS disk"
  type        = string
  default     = "Premium_LRS"
}

variable "vm_os_disk_image" {
  description = "Specifies the OS disk image of the virtual machine"
  type        = map(string)
  default     = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

variable "domain_name_label" {
  description = "Specifies the domain name label for the virtual machine"
  type        = string
  default     = "babotestvm"
}

variable "admin_username" {
  description = "(Required) Specifies the admin username for the virtual machine"
  type        = string
  default     = "azadmin"
}

variable "ssh_public_key" {
  description = "(Required) Specifies the SSH public key for the virtual machine"
  type        = string
}

variable "script_storage_account_name" {
  description = "(Required) Specifies the name of the storage account that contains the custom script"
  type        = string
}

variable "script_storage_account_key" {
  description = "(Required) Specifies the storage account key for the custom script"
  type        = string
}

variable "container_name" {
  description = "(Required) Specifies the name of the container that contains the custom script"
  type        = string
  default     = "scripts"
}

variable "script_name" {
  description = "(Required) Specifies the name of the custom script"
  type        = string
  default     = "configure-jumpbox-vm.sh"
}

######################
# Storage Account (for Data Lake / Boot Diagnostics)
######################
variable "storage_account_kind" {
  description = "(Optional) Specifies the account kind for the storage account"
  type        = string
  default     = "StorageV2"
}

variable "storage_account_tier" {
  description = "(Optional) Specifies the account tier for the storage account"
  type        = string
  default     = "Standard"
}

variable "storage_account_replication_type" {
  description = "(Optional) Specifies the replication type for the storage account"
  type        = string
  default     = "LRS"
}

######################
# Container Registry
######################
variable "acr_name" {
  description = "Specifies the name of the container registry"
  type        = string
  default     = "BaboAcr"
}

variable "acr_sku" {
  description = "Specifies the SKU of the container registry"
  type        = string
  default     = "Premium"
}

variable "acr_admin_enabled" {
  description = "Specifies whether admin is enabled for the container registry"
  type        = bool
  default     = true
}

variable "acr_georeplication_locations" {
  description = "(Optional) A list of Azure regions where the container registry should be geo-replicated"
  type        = list(string)
  default     = []
}

######################
# Key Vault
######################
variable "key_vault_name" {
  description = "Specifies the name of the Key Vault"
  type        = string
  default     = "BaboAksKeyVault"
}

variable "key_vault_sku_name" {
  description = "(Required) The SKU name for the Key Vault. Possible values are standard and premium."
  type        = string
  default     = "standard"
}

variable "key_vault_enabled_for_deployment" {
  description = "(Optional) Whether VMs are permitted to retrieve certificates stored as secrets"
  type        = bool
  default     = true
}

variable "key_vault_enabled_for_disk_encryption" {
  description = "(Optional) Whether Azure Disk Encryption can retrieve secrets from the vault"
  type        = bool
  default     = true
}

variable "key_vault_enabled_for_template_deployment" {
  description = "(Optional) Whether ARM is permitted to retrieve secrets from the Key Vault"
  type        = bool
  default     = true
}

variable "key_vault_enable_rbac_authorization" {
  description = "(Optional) Whether the Key Vault uses RBAC for data actions"
  type        = bool
  default     = true
}

variable "key_vault_purge_protection_enabled" {
  description = "(Optional) Whether purge protection is enabled for the Key Vault"
  type        = bool
  default     = true
}

variable "key_vault_soft_delete_retention_days" {
  description = "(Optional) The number of days items should be retained after soft-delete"
  type        = number
  default     = 30
}

variable "key_vault_bypass" {
  description = "(Required) Specifies which traffic can bypass network rules (AzureServices or None)"
  type        = string
  default     = "AzureServices"
}

variable "key_vault_default_action" {
  description = "(Required) Specifies the default action when no rules match (Allow or Deny)"
  type        = string
  default     = "Allow"
}
