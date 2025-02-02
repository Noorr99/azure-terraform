variable "resource_group_name" {
  description = "The name of the Resource Group where Data Factory will be created."
  type        = string
}

variable "location" {
  description = "The Azure location where Data Factory will be created."
  type        = string
}

variable "data_factory_name" {
  description = "The name of the Azure Data Factory."
  type        = string
}

variable "tags" {
  description = "A map of tags for the Data Factory."
  type        = map(string)
  default     = {}
}

variable "public_network_enabled" {
  description = "Specifies whether the Data Factory is visible to the public network."
  type        = bool
}

variable "data_factory_identity_type" {
  description = "Specifies the identity type for the Data Factory. Valid values include 'SystemAssigned', 'UserAssigned' or 'SystemAssigned, UserAssigned' (for both)."
  type        = string
}