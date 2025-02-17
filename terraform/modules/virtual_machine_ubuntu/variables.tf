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

variable "subnet_id" {
  description = "(Required) Specifies the resource ID of the subnet hosting the virtual machine"
  type        = string
}

variable "zone" {
  description = "The Availability Zone where the VM should be created. Valid values are 1, 2, or 3."
  type        = number
  default     = 1
  
  validation {
    condition     = contains([1, 2, 3], var.zone)
    error_message = "Zone must be 1, 2, or 3."
  }
}