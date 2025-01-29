// Databricks Subnets Outputs
output "databricks_private_subnet_name" {
  value       = module.databricks_subnets.private_subnet_name
  description = "Name of the private subnet for Databricks"
}

output "databricks_private_subnet_id" {
  value       = module.databricks_subnets.private_subnet_id
  description = "ID of the private subnet for Databricks"
}

output "databricks_public_subnet_name" {
  value       = module.databricks_subnets.public_subnet_name
  description = "Name of the public subnet for Databricks"
}

output "databricks_public_subnet_id" {
  value       = module.databricks_subnets.public_subnet_id
  description = "ID of the public subnet for Databricks"
}

// Databricks Security Groups Outputs
output "databricks_private_sg_name" {
  value       = module.databricks_security_groups.security_group_private_name
  description = "Name of security group assigned to the private Databricks subnet"
}

output "databricks_private_sg_id" {
  value       = module.databricks_security_groups.security_group_private_id
  description = "ID of security group assigned to the private Databricks subnet"
}

output "databricks_public_sg_name" {
  value       = module.databricks_security_groups.security_group_public_name
  description = "Name of security group assigned to the public Databricks subnet"
}

output "databricks_public_sg_id" {
  value       = module.databricks_security_groups.security_group_public_id
  description = "ID of security group assigned to the public Databricks subnet"
}

// Databricks Workspace Outputs
output "databricks_workspace_name" {
  value       = module.databricks_workspace.workspace_name
  description = "Name of the Databricks workspace"
}

output "databricks_workspace_id" {
  value       = module.databricks_workspace.workspace_id
  description = "ID of the Databricks workspace"
}

output "vm_ids" {
  description = "The IDs of the Windows virtual machines."
  value       = [for vm in module.virtual_machine : vm.vm_id]
}