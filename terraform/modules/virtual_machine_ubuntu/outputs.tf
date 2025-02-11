output "ubuntu_vm_id" {
  description = "The ID(s) of the Ubuntu virtual machine(s)."
  value       = azurerm_linux_virtual_machine.ubuntu_vm[*].id
}

output "ubuntu_public_ip_address" {
  description = "The public IP address of the Ubuntu virtual machine (if one was created)."
  value       = length(azurerm_public_ip.ubuntu_public_ip) > 0 ? azurerm_public_ip.ubuntu_public_ip[0].ip_address : ""
}
