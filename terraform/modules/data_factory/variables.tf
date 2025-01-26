variable "resource_group_name" {
  description = "Name of the Resource Group for Data Factory"
  type        = string
}

variable "location" {
  description = "Azure region for Data Factory"
  type        = string
}

variable "data_factory_name" {
  description = "Name of the Azure Data Factory"
  type        = string
}

variable "tags" {
  description = "A map of tags for the Data Factory"
  type        = map(string)
  default     = {}
}
