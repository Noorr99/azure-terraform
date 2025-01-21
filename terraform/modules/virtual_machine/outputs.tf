output "public_ip" {
  description = "Specifies the public IP address of the virtual machine (if one is created)."
  # If a public IP exists, output its IP address; otherwise, output an empty string.
  value       = length(azurerm_public_ip.public_ip) > 0 ? azurerm_public_ip.public_ip[0].ip_address : ""
}

output "username" {
  description = "Specifies the username of the virtual machine."
  value       = var.vm_user
}
