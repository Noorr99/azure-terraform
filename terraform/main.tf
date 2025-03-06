terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.50"
    }
  }

  backend "azurerm" {
    # Backend configuration details (adjust as needed)
    resource_group_name  = "RG-QCH-JB-001"
    storage_account_name = "stnihstate001"
    container_name       = "tfstatedtmdev"
    key                  = "terraform.tfstate"
    subscription_id      = "751b8a58-5878-4c86-93dc-13c41b3a90cf"
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

/*
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}
*/

//
// Virtual Network Module – includes two subnets: one for VMs and one for private endpoints.
//
module "vnet" {
  source              = "./modules/virtual_network"
  resource_group_name = var.resource_group_name
  location            = var.location
  vnet_name           = var.dtm_vnet_name
  address_space       = var.dtm_vnet_address_space

  # Two subnets are provided to the vnet module.
  subnets = [
    {
      name                                          = var.vm_subnet_name
      address_prefixes                              = var.vm_subnet_address_prefix
      private_endpoint_network_policies_enabled     = true
      private_link_service_network_policies_enabled = false
    },
    {
      name                                          = var.data_subnet_name
      address_prefixes                              = var.data_subnet_address_prefix
      private_endpoint_network_policies_enabled     = true
      private_link_service_network_policies_enabled = false
    },
    {
      name                                          = var.pe_subnet_name
      address_prefixes                              = var.pe_subnet_address_prefix
      # For private endpoints, network policies must be disabled.
      private_endpoint_network_policies_enabled     = false
      # Enable private link service network policies if needed.
      private_link_service_network_policies_enabled = true
    }
  ]
}

/*
locals {
  cross_vm_names_zones_indexed = flatten([
    // For each VM name in var.vm_names...
    for k, vm_name in var.vm_names : [
      // ...loop over var.zone with an index (zone_index).
      // zone_index starts at 0 for the first zone, 1 for the second, etc.
      for zone_index, z in var.zone : {
        base_name = vm_name
        zone      = z
        // index_str => "01" if zone_index=0, "02" if zone_index=1, etc.
        index_str = format("%02d", zone_index + 1)
      }
    ]
  ])
}
*/

/*
locals {
  cross_vm_names_zones_indexed = [
    for i, vm_name in var.vm_names : {
      base_name = vm_name
      // index_str => "01" if i=0, "02" if i=1, etc.
      index_str = format("%02d", i + 1)
    }
  ]
}
*/

module "virtual_machine" {
//  count               = var.vm_count
//  count               = length(var.vm_names)
//  for_each = var.vm_names

/*
for_each = {
  for combo in local.cross_vm_names_zones_indexed :
  "${combo.base_name}-${combo.index_str}" => combo
}
*/
  source              = "./modules/virtual_machine"

  name                = var.vm_name
//  zone                = each.value.zone
//  index_str           = each.value.index_str
  size                = var.vm_size
  location            = var.location
  public_ip           = var.vm_public_ip
  vm_user             = var.admin_username
  admin_password      = var.admin_password      // Provided at runtime
  os_disk_image       = var.vm_os_disk_image
  domain_name_label   = var.domain_name_label
  resource_group_name = var.resource_group_name
  tags                = var.tags

  subnet_id                   = module.vnet.subnet_ids[var.vm_subnet_name]
  os_disk_storage_account_type = var.vm_os_disk_storage_account_type
  os_disk_size_gb = var.os_disk_size_gb
  # Pass the ID of the availability set
//  availability_set_id = azurerm_availability_set.vm_avset.id
}



////////////////////////////////////////////////////////////////////////
// 6. SQL Database + Private Endpoint + DNS
////////////////////////////////////////////////////////////////////////
module "sql_database" {
  source                   = "./modules/sql_database"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  sql_server_name          = var.sql_server_name
  sql_admin_username       = var.sql_admin_username
  sql_admin_password       = var.sql_admin_password   // Provided at runtime
  sql_database_name        = var.sql_database_name
  sql_database_dtu         = var.sql_database_dtu
  sql_database_tier        = var.sql_database_tier
  sql_database_size_gb     = var.sql_database_size_gb
  long_term_retention_backup = var.long_term_retention_backup
  zone_redundant           = var.zone_redundant
  geo_backup_enabled       = var.geo_backup_enabled
  storage_account_type     = var.storage_account_type
  sku_name                 = var.sku_name  
  # re-use the shared subnet for SQL
  subnet_id                = module.vnet.subnet_ids[var.data_subnet_name]
  private_dns_zone_id      = module.sql_private_dns_zone.id
  tags                     = var.tags
}

module "sql_private_dns_zone" {
  source                   = "./modules/private_dns_zone"
  name                     = "privatelink.database.windows.net"
  resource_group_name      = var.resource_group_name
  virtual_networks_to_link = {
    (module.vnet.name) = {
      subscription_id     = data.azurerm_client_config.current.subscription_id
      resource_group_name = var.resource_group_name
    }
  }
  tags = var.tags
}



////////////////////////////////////////////////////////////////////////
// 6. Cognitive Service (Azure AI Custom Vision, Standard Tier)
//    + Private Endpoint + DNS
////////////////////////////////////////////////////////////////////////
/*
resource "random_string" "cognitive_account_suffix" {
  length  = 13
  lower   = true
  numeric = false
  special = false
  upper   = false
}
*/

resource "azurerm_cognitive_account" "cognitive_service" {
  name                          = var.cognitive_service_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  kind                          = var.cognitive_service_kind  // e.g., "TextAnalytics"
  sku_name                      = var.cognitive_service_sku
  tags                          = var.tags
  custom_subdomain_name         = var.cognitive_custom_subdomain_name
  public_network_access_enabled = var.cognitive_public_network_access_enabled
}

module "cognitive_dns_zone" {
  source              = "./modules/private_dns_zone"
  name                = "privatelink.cognitiveservices.azure.com"
  resource_group_name = var.resource_group_name
  virtual_networks_to_link = {
    (module.vnet.name) = {
      subscription_id     = data.azurerm_client_config.current.subscription_id
      resource_group_name = var.resource_group_name
    }
  }
  tags = var.tags
}

module "cognitive_private_endpoint" {
  source                         = "./modules/private_endpoint"
  name                           = var.cognitive_service_name
  location                       = var.location
  resource_group_name            = var.resource_group_name
  // For private endpoints, it’s recommended to use a subnet with private endpoint network policies disabled.
  subnet_id                      = module.vnet.subnet_ids[var.pe_subnet_name]
  private_connection_resource_id = azurerm_cognitive_account.cognitive_service.id
  // The subresource for cognitive accounts remains "account"
  subresource_name               = "account"
  private_dns_zone_group_name    = "CognitivePrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.cognitive_dns_zone.id]
  tags                           = var.tags
}





/*
module "sql_private_endpoint" {
  source                         = "./modules/private_endpoint"
  name                           = "${var.sql_server_name}-pe"
  location                       = var.location
  resource_group_name            = var.resource_group_name
  subnet_id                      = module.vnet.subnet_ids[var.pe_subnet_name]
  private_connection_resource_id = module.sql_database.id
  subresource_name               = "sqlServer"
  private_dns_zone_group_name    = "SqlPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.sql_private_dns_zone.id]
  tags                           = var.tags
}
*/
