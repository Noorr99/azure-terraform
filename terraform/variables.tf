// Resource Group Variables
variable "resource_group_name" {
  description = "Specifies the name of the resource group."
  type        = string
  default     = "VMRG"
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

// Virtual Network (VNet) Variables
variable "aks_vnet_name" {
  description = "Specifies the name of the Azure virtual network."
  type        = string
  default     = "VMVNet"
}

variable "aks_vnet_address_space" {
  description = "Specifies the address space for the Azure virtual network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "vm_subnet_name" {
  description = "Specifies the name of the subnet for the virtual machine."
  type        = string
  default     = "VmSubnet"
}

variable "vm_subnet_address_prefix" {
  description = "Specifies the address prefix for the VM subnet."
  type        = list(string)
  default     = ["10.0.48.0/20"]
}

// Virtual Machine (VM) Variables
variable "vm_name" {
  description = "Specifies the name of the virtual machine."
  type        = string
  default     = "TestVm"
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

variable "domain_name_label" {
  description = "Specifies the domain name label for the virtual machine."
  type        = string
  default     = "windowsnpcvmtrial"
}

variable "vm_os_disk_storage_account_type" {
  description = "Specifies the storage account type for the OS disk of the virtual machine."
  type        = string
  default     = "Premium_LRS"

  validation {
    condition     = contains(
      ["Premium_LRS", "Premium_ZRS", "StandardSSD_LRS", "StandardSSD_ZRS", "Standard_LRS"],
      var.vm_os_disk_storage_account_type
    )
    error_message = "The storage account type for the OS disk is invalid. Valid options are Premium_LRS, Premium_ZRS, StandardSSD_LRS, StandardSSD_ZRS, Standard_LRS."
  }
}
