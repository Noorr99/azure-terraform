// Existing resource group and network variables remain here...

// Virtual Machine (VM) Variables
variable "vm_name" {
  description = "Specifies the base name of the virtual machine."
  type        = string
  default     = "TestVm"
}

variable "vm_count" {
  description = "The number of virtual machines to create."
  type        = number
  default     = 1
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
