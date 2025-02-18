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
    container_name       = "tfstatesrprod"
    key                  = "terraform.tfstate"
    subscription_id      = "751b8a58-5878-4c86-93dc-13c41b3a90cf"
  }
}

provider "azurerm" {
  features {}
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
  vnet_name           = var.aks_vnet_name
  address_space       = var.aks_vnet_address_space

  # Two subnets are provided to the vnet module.
  subnets = [
    {
      name                                          = var.vm_subnet_name
      address_prefixes                              = var.vm_subnet_address_prefix
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

//
// Availability Set Module
//
/*
resource "azurerm_availability_set" "vm_avset" {
  name                = var.availability_set_name
  location            = var.location
  resource_group_name = var.resource_group_name

  platform_fault_domain_count  = 2
  platform_update_domain_count = 5
  managed                      = true
  tags                         = var.tags
}
*/
//
// Virtual Machine Module
//
/*

locals {
  # Build a list of objects from all vm_names × zones
  cross_vm_names_zones = flatten([
    for k, vm_name in var.vm_names : [
      for z in var.zone : {
        map_key = "${k}-z${z}"   # Unique key for each combination
        name    = vm_name        # e.g. "sr-shir"
        zone    = z              # e.g. "2"
      }
    ]
  ])
}
*/

locals {
  # (A) Cross product of vm_names and zone, no index yet.
  cross_vm_names_zones_no_index = flatten([
    for k, vm_name in var.vm_names : [
      for z in var.zone : {
        # We'll store the original base name and the zone
        base_name = vm_name
        zone      = z
      }
    ]
  ])

  # (B) Add a 2-digit index to each item (01, 02, 03, ...).
  # i starts at 0, so we do (i+1) for 1-based counting.
  cross_vm_names_zones_indexed = [
    for i, combo in local.cross_vm_names_zones_no_index : merge(combo, {
      index_str = format("%02d", i + 1)
    })
  ]
}

module "virtual_machine" {
//  count               = var.vm_count
//  count               = length(var.vm_names)
//  for_each = var.vm_names
/*
  for_each = {
    for combo in local.cross_vm_names_zones :
    combo.map_key => combo
  }
*/
  for_each = {
    for combo in local.cross_vm_names_zones_indexed :
    # For uniqueness: combine the base_name + index
    "${combo.base_name}-${combo.index_str}" => combo
  }
  source              = "./modules/virtual_machine"

  name                = each.value.base_name
  zone                = each.value.zone
  index_str           = each.value.index_str
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
  # Pass the ID of the availability set
//  availability_set_id = azurerm_availability_set.vm_avset.id
}


// Virtual Machine Ubuntu

module "ubuntu_vm" {
  source              = "./modules/virtual_machine_ubuntu"  # Adjust the path accordingly

  resource_group_name            = var.resource_group_name
  location                       = var.location
  tags                           = var.tags

  ubuntu_vm_name                 = var.ubuntu_vm_name
  ubuntu_vm_count                = var.ubuntu_vm_count
  ubuntu_vm_size                 = var.ubuntu_vm_size
  ubuntu_vm_public_ip            = var.ubuntu_vm_public_ip
  ubuntu_admin_username          = var.ubuntu_admin_username
  ubuntu_admin_password          = var.ubuntu_admin_password
  ubuntu_vm_os_disk_image        = var.ubuntu_vm_os_disk_image
  ubuntu_domain_name_label       = var.ubuntu_domain_name_label
  ubuntu_vm_os_disk_storage_account_type = var.ubuntu_vm_os_disk_storage_account_type
  subnet_id                   = module.vnet.subnet_ids[var.vm_subnet_name]
}


//
// Key Vault Module Deployment
//
module "key_vault" {
  source              = "./modules/key_vault"
  name                = var.key_vault_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tenant_id           = var.tenant_id         // Provided at runtime
  sku_name            = var.key_vault_sku
  tags                = var.tags

  enabled_for_deployment          = var.key_vault_enabled_for_deployment
  enabled_for_disk_encryption     = var.key_vault_enabled_for_disk_encryption
  enabled_for_template_deployment = var.key_vault_enabled_for_template_deployment
  enable_rbac_authorization       = var.key_vault_enable_rbac_authorization
  purge_protection_enabled        = var.key_vault_purge_protection_enabled
  soft_delete_retention_days      = var.key_vault_soft_delete_retention_days
  public_network_access_enabled   = var.public_network_access_enabled

  bypass                        = var.key_vault_bypass
  default_action                = var.key_vault_default_action
  ip_rules                      = var.key_vault_ip_rules
  # With private endpoints in use, leave virtual_network_subnet_ids empty
  virtual_network_subnet_ids    = []
}

//
// ACR Module Deployment
//
module "acr" {
  source              = "./modules/container_registry"
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  admin_enabled       = var.acr_admin_enabled
  sku                 = var.acr_sku
  tags                = var.tags
  public_network_access_enabled = var.public_network_access_enabled

  georeplication_locations = var.acr_georeplication_locations
  zone_redundancy_enabled = var.zone_redundancy_enabled
}

module "acr_private_dns_zone" {
  source                       = "./modules/private_dns_zone"
  name                         = "privatelink.azurecr.io"
  resource_group_name          = var.resource_group_name
  virtual_networks_to_link     = {
    (module.vnet.name) = {
      subscription_id    = data.azurerm_client_config.current.subscription_id
      resource_group_name = var.resource_group_name
    }
  }
  tags                         = var.tags
}

module "acr_private_endpoint" {
  source                         = "./modules/private_endpoint"
  name                           = "pe-${var.acr_name_pe}"
  location                       = var.location
  resource_group_name            = var.resource_group_name
  subnet_id                      = module.vnet.subnet_ids[var.pe_subnet_name]
  tags                           = var.tags
  private_connection_resource_id = module.acr.id
  is_manual_connection           = false
  subresource_name               = "registry"
  private_dns_zone_group_name    = "AcrPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.acr_private_dns_zone.id]
}

module "keyvault_private_dns_zone" {
  source                       = "./modules/private_dns_zone"
  name                         = "privatelink.vaultcore.azure.net"
  resource_group_name          = var.resource_group_name
  virtual_networks_to_link     = {
    (module.vnet.name) = {
      subscription_id    = data.azurerm_client_config.current.subscription_id
      resource_group_name = var.resource_group_name
    }
  }
  tags                         = var.tags
}

module "keyvault_private_endpoint" {
  source                         = "./modules/private_endpoint"
  name                           = "pe-${module.key_vault.name}"
  location                       = var.location
  resource_group_name            = var.resource_group_name
  subnet_id                      = module.vnet.subnet_ids[var.pe_subnet_name]
  tags                           = var.tags
  private_connection_resource_id = module.key_vault.id
  is_manual_connection           = false
  subresource_name               = "vault"
  private_dns_zone_group_name    = "KeyVaultPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.keyvault_private_dns_zone.id]
}

module "databricks_subnets" {
  source                      = "./modules/azure-databricks-subnets"
  subnet_name_prefix          = "snet-dbw"
  vnet_name                   = var.aks_vnet_name
  vnet_resource_group_name    = var.resource_group_name
  private_subnet_address_prefixes = var.private_subnet_address_prefixes
  public_subnet_address_prefixes  = var.public_subnet_address_prefixes
  service_delegation_actions  = [
    "Microsoft.Network/virtualNetworks/subnets/join/action",
    "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
    "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
  ]
  additional_service_endpoints = ["Microsoft.Storage"]
  tags                        = var.tags
  depends_on = [module.vnet]
}

module "databricks_security_groups" {
  source                     = "./modules/azure-databricks-security-groups"
  security_group_name_prefix = var.databricks_security_group_prefix
  location                   = var.location
  vnet_resource_group_name   = var.resource_group_name
  private_subnet_id          = module.databricks_subnets.private_subnet_id
  public_subnet_id           = module.databricks_subnets.public_subnet_id
  tags                       = var.tags
  depends_on = [module.databricks_subnets]
}

module "databricks_workspace" {
  source               = "./modules/azure-databricks-workspace"
  workspace_name       = var.workspace_name
  resource_group_name  = var.resource_group_name
  location             = var.location
  sku                  = var.sku_dbw
  vnet_id              = module.vnet.vnet_id
  private_subnet_name  = module.databricks_subnets.private_subnet_name
  public_subnet_name   = module.databricks_subnets.public_subnet_name
  public_subnet_network_security_group_association_id = module.databricks_security_groups.security_group_public_id
  private_subnet_network_security_group_association_id = module.databricks_security_groups.security_group_private_id
  tags                 = var.tags
  public_network_access_enabled = var.public_network_access_enabled
  vnet_name            = var.aks_vnet_name
  managed_resource_group_name = var.managed_resource_group_name

  depends_on = [module.databricks_subnets, module.databricks_security_groups]
}

//add pe for dbw:


module "databricks_private_dns_zone" {
  source                       = "./modules/private_dns_zone"
  name                         = "privatelink.azuredatabricks.net"
  resource_group_name          = var.resource_group_name
  virtual_networks_to_link     = {
    (module.vnet.name) = {
      subscription_id    = data.azurerm_client_config.current.subscription_id
      resource_group_name = var.resource_group_name
    }
  }
  tags                         = var.tags
}
/*
module "databricks_private_endpoint" {
  source                         = "./modules/private_endpoint"
  name                           = "pe-${module.databricks_workspace.workspace_name}"
  location                       = var.location
  resource_group_name            = var.resource_group_name
  subnet_id                      = module.vnet.subnet_ids[var.pe_subnet_name]
  tags                           = var.tags
  private_connection_resource_id = module.databricks_workspace.workspace_id
  is_manual_connection           = false
  subresource_name               = "databricks"
  private_dns_zone_group_name    = "DatabricksPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.databricks_private_dns_zone.id]
}
*/
# Create a Private Endpoint for the Azure Databricks workspace
resource "azurerm_private_endpoint" "databricks" {
  name                = "pe-${module.databricks_workspace.workspace_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = module.vnet.subnet_ids[var.pe_subnet_name]

  # Use a custom network interface name as seen in the manual creation
  custom_network_interface_name = "pe-${module.databricks_workspace.workspace_name}-nic"

  private_service_connection {
    name                           = "pe-${module.databricks_workspace.workspace_name}-conn"
    private_connection_resource_id = module.databricks_workspace.workspace_id
    is_manual_connection           = false
    # This subresource name ("databricks_ui_api") is taken from your JSON example.
    subresource_names              = ["databricks_ui_api"]
  }
}


resource "azurerm_storage_account" "datalake_storage_account" {
  name                     = var.datalake_storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.datalake_account_tier
  account_replication_type = var.datalake_account_replication_type
  account_kind             = var.datalake_account_kind
  is_hns_enabled           = var.datalake_is_hns_enabled
  tags                     = var.tags
  public_network_access_enabled = var.public_network_access_enabled

/*
  blob_properties {
    delete_retention_policy {
      days = var.soft_delete_retention_days   # Adjust retention period as needed
    }
    container_delete_retention_policy {
      days = var.soft_delete_retention_days   # Adjust retention period as needed
    }
    versioning_enabled = var.enable_versioning
    change_feed_enabled = var.enable_change_feed
  }
*/
}

data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "storage_blob_data_owner" {
  scope                = azurerm_storage_account.datalake_storage_account.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "contributor" {
  scope                = azurerm_storage_account.datalake_storage_account.id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "time_sleep" "role_assignment_sleep" {
  create_duration = "60s"

  triggers = {
    role_assignment = azurerm_role_assignment.storage_blob_data_owner.id
  }
}

resource "azurerm_storage_data_lake_gen2_filesystem" "datalake_filesystem" {
  name               = var.datalake_filesystem_name
  storage_account_id = azurerm_storage_account.datalake_storage_account.id

  properties = var.datalake_filesystem_properties

  depends_on = [
    azurerm_storage_account.datalake_storage_account,
    time_sleep.role_assignment_sleep
  ]
}

// Datalake endpoint and private DNS

module "datalake_private_dns_zone" {
  source                       = "./modules/private_dns_zone"
  name                         = "privatelink.dfs.core.windows.net"
  resource_group_name          = var.resource_group_name
  virtual_networks_to_link     = {
    (module.vnet.name) = {
      subscription_id    = data.azurerm_client_config.current.subscription_id
      resource_group_name = var.resource_group_name
    }
  }
  tags                         = var.tags
}

module "datalake_private_endpoint" {
  source                         = "./modules/private_endpoint"
  name                           = "pe-${var.datalake_storage_account_pe}"
  location                       = var.location
  resource_group_name            = var.resource_group_name
  subnet_id                      = module.vnet.subnet_ids[var.pe_subnet_name]
  tags                           = var.tags
  private_connection_resource_id = azurerm_storage_account.datalake_storage_account.id
  is_manual_connection           = false
  subresource_name               = "dfs"
  private_dns_zone_group_name    = "DatalakePrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.datalake_private_dns_zone.id]
}
