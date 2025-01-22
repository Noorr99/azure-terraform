variable "workspace_name" {
  description = "Name of the Databricks workspace."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region for deployment."
  type        = string
}

variable "vnet_id" {
  description = "ID of the existing virtual network."
  type        = string
}

variable "public_subnet_id" {
  description = "ID of the public subnet for Databricks."
  type        = string
}

variable "private_subnet_id" {
  description = "ID of the private subnet for Databricks."
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
}
