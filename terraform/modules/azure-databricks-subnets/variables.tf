variable "subnet_name_prefix" {
  type        = string
  description = "Prefix for the names of the subnets created by this module"
  default     = "tamr-databricks"
}

variable "vnet_name" {
  type        = string
  description = "Name of the existing virtual network into which Databricks will be deployed"
}

variable "vnet_resource_group_name" {
  type        = string
  description = "Name of the resource group that contains the virtual network"
}

variable "private_subnet_address_prefixes" {
  type        = list(string)
  description = "Address space for the private Databricks subnet"
}

variable "public_subnet_address_prefixes" {
  type        = list(string)
  description = "Address space for the public Databricks subnet"
}

variable "service_delegation_actions" {
  type        = list(string)
  description = <<EOF
A list of actions to delegate for the subnet.
This list is specific to the service being delegated to.
EOF
  default = [
    "Microsoft.Network/virtualNetworks/subnets/join/action",
    "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
    "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
  ]
}

variable "additional_service_endpoints" {
  type        = list(string)
  description = <<EOT
List of additional Virtual Network service endpoints.
Note: This module internally adds `Microsoft.AzureActiveDirectory` and `Microsoft.Sql` endpoints to the created subnets.
EOT
  default = ["Microsoft.Storage"]
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to attach to Databricks subnets"
  default     = {}
}
