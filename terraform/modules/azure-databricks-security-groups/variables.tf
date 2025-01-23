variable "security_group_name_prefix" {
  description = "Prefix for Databricks security groups."
  type        = string
}

variable "location" {
  description = "Azure region for deployment."
  type        = string
}

variable "vnet_resource_group_name" {
  description = "Resource group name of the virtual network."
  type        = string
}

variable "private_subnet_id" {
  description = "ID of the private subnet for Databricks."
  type        = string
}

variable "public_subnet_id" {
  description = "ID of the public subnet for Databricks."
  type        = string
}

variable "tags" {
  description = "Tags to apply to security groups."
  type        = map(string)
}
