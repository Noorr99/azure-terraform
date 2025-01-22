variable "name" {
  description = "The name of the Azure Databricks workspace."
  type        = string
}

variable "resource_group_name" {
  description = "The resource group for the Databricks workspace."
  type        = string
}

variable "location" {
  description = "The Azure location for the Databricks workspace."
  type        = string
}

variable "sku" {
  description = "The SKU for the Databricks workspace (e.g., standard or premium)."
  type        = string
  default     = "standard"
}

variable "virtual_network_id" {
  description = "The ID of the virtual network into which Databricks will be injected."
  type        = string
}

variable "virtual_network_name" {
  description = "The name of the virtual network into which Databricks will be injected."
  type        = string
}

variable "public_subnet_name" {
  description = "The name of the public subnet for Databricks."
  type        = string
}

variable "private_subnet_name" {
  description = "The name of the private subnet for Databricks."
  type        = string
}

variable "tags" {
  description = "Tags for the Databricks workspace."
  type        = map(string)
  default     = {}
}
