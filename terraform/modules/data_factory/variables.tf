variable "resource_group_name" {
  description = "The name of the resource group in which to create the Data Factory."
  type        = string
}

variable "location" {
  description = "The Azure location where the Data Factory will be created."
  type        = string
}

variable "data_factory_name" {
  description = "The name of the Data Factory. Must be globally unique."
  type        = string
}
