variable "resource_group_name" {
  description = "The name of the Resource Group where Data Factory will be created."
  type        = string
}

variable "location" {
  description = "The Azure location where Data Factory will be created."
  type        = string
}

variable "data_factory_name" {
  description = "The name of the Data Factory."
  type        = string
}

variable "tags" {
  description = "A map of tags for the Data Factory resource."
  type        = map(string)
  default     = {}
}
