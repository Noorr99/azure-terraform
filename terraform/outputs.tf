#
# Outputs from Databricks Workspace Module
#

output "workspace_name" {
  value       = module.databricks_workspace.workspace_name
  description = "Name of the Databricks workspace"
}

output "workspace_id" {
  value       = module.databricks_workspace.workspace_id
  description = "ID of the Databricks workspace"
}

#
# Outputs from Databricks Security Groups Module
#

output "security_group_private_name" {
  value       = module.databricks_security_groups.security_group_private_name
  description = "Name of security group assigned to the private subnet"
}

output "security_group_private_id" {
  value       = module.databricks_security_groups.security_group_private_id
  description = "ID of security group assigned to the private subnet"
}

output "security_group_public_name" {
  value       = module.databricks_security_groups.security_group_public_name
  description = "Name of security group assigned to the public subnet"
}

output "security_group_public_id" {
  value       = module.databricks_security_groups.security_group_public_id
  description = "ID of security group assigned to the public subnet"
}

#
# Outputs from Databricks Subnets Module
#

output "databricks_public_subnet_id" {
  value       = module.databricks_subnets.public_subnet_id
  description = "ID of the Databricks public subnet"
}

output "databricks_private_subnet_id" {
  value       = module.databricks_subnets.private_subnet_id
  description = "ID of the Databricks private subnet"
}

output "databricks_public_subnet_name" {
  value       = module.databricks_subnets.public_subnet_name
  description = "Name of the Databricks public subnet"
}

output "databricks_private_subnet_name" {
  value       = module.databricks_subnets.private_subnet_name
  description = "Name of the Databricks private subnet"
}
