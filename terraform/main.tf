terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.50"
    }
  }

  backend "azurerm" {
    # backend configuration details here (if any)
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

//
// Virtual Network Module – includes two subnets: one for VMs and one for private endpoints.
//
module "vnet" {
  source              = "./modules/virtual_network"
  resource_group_name = azurerm_resource_group.rg.name
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
// Virtual Machine Module (unchanged)
//
module "virtual_machine" {
  count               = var.vm_count
  source              = "./modules/virtual_machine"

  name                = "${count.index}-${var.vm_name}"
  size                = var.vm_size
  location            = var.location
  public_ip           = var.vm_public_ip
  vm_user             = var.admin_username
  admin_password      = var.admin_password
  os_disk_image       = var.vm_os_disk_image
  domain_name_label   = var.domain_name_label
  resource_group_name = azurerm_resource_group.rg.name

  subnet_id                   = module.vnet.subnet_ids[var.vm_subnet_name]
  os_disk_storage_account_type = var.vm_os_disk_storage_account_type
}

//
// Key Vault Module Deployment
//
module "key_vault" {
  source              = "./modules/key_vault"
  name                = var.key_vault_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  tenant_id           = var.tenant_id
  sku_name            = var.key_vault_sku
  tags                = var.tags

  enabled_for_deployment          = var.key_vault_enabled_for_deployment
  enabled_for_disk_encryption     = var.key_vault_enabled_for_disk_encryption
  enabled_for_template_deployment = var.key_vault_enabled_for_template_deployment
  enable_rbac_authorization       = var.key_vault_enable_rbac_authorization
  purge_protection_enabled        = var.key_vault_purge_protection_enabled
  soft_delete_retention_days      = var.key_vault_soft_delete_retention_days

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
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  admin_enabled       = var.acr_admin_enabled
  sku                 = var.acr_sku
  tags                = var.tags

  georeplication_locations = var.acr_georeplication_locations
}

//
// Private Endpoint for Key Vault
//
resource "azurerm_private_endpoint" "key_vault_pe" {
  name                = "${var.key_vault_name}-pe"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  subnet_id = module.vnet.subnet_ids[var.pe_subnet_name]

  private_service_connection {
    name                           = "${var.key_vault_name}-psc"
    private_connection_resource_id = module.key_vault.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }
}

//
// Private Endpoint for ACR
//
/*
resource "azurerm_private_endpoint" "acr_pe" {
  name                = "${var.acr_name}-pe"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  subnet_id = module.vnet.subnet_ids[var.pe_subnet_name]

  private_service_connection {
    name                           = "${var.acr_name}-psc"
    private_connection_resource_id = module.acr.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }
}
*/

/*
module "private_dns_zone_acr" {
  source              = "./modules/private_dns_zone"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_zone_name       = "privatelink.azurecr.io"
  vnet_id             = module.vnet.vnet_id
}

module "private_endpoint_acr" {
  source                        = "./modules/private_endpoint"
  name                          = "${var.acr_name}-pe"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg.name
  subnet_id                     = module.vnet.subnet_ids[var.pe_subnet_name]
  private_connection_resource_id = module.acr.id
  is_manual_connection          = false
  subresource_name              = "registry"
  private_dns_zone_group_name   = "${var.acr_name}-pdns"
  private_dns_zone_group_ids    = [module.private_dns_zone_acr.id]
  tags                          = var.tags
}
*/

module "acr_private_dns_zone" {
  source                       = "./modules/private_dns_zone"
  name                         = "privatelink.azurecr.io"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_networks_to_link     = var.aks_vnet_name

module "acr_private_endpoint" {
  source                         = "./modules/private_endpoint"
  name                           = "${module.container_registry.name}PrivateEndpoint"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.rg.name
  subnet_id                      = module.aks_network.subnet_ids[var.vm_subnet_name]
  tags                           = var.tags
  private_connection_resource_id = module.container_registry.id
  is_manual_connection           = false
  subresource_name               = "registry"
  private_dns_zone_group_name    = "AcrPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.acr_private_dns_zone.id]
}


module "databricks_subnets" {
  source                      = "./modules/azure-databricks-subnets"
  subnet_name_prefix          = "databricks"
  vnet_name                   = var.aks_vnet_name // Changed to use variable
  vnet_resource_group_name    = azurerm_resource_group.rg.name
  private_subnet_address_prefixes = ["10.0.2.0/24"] // Adjust as needed
  public_subnet_address_prefixes  = ["10.0.3.0/24"] // Adjust as needed
  service_delegation_actions  = [
    "Microsoft.Network/virtualNetworks/subnets/join/action",
    "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
    "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
  ]
  additional_service_endpoints = ["Microsoft.Storage"]
  tags                        = var.databricks_tags
}

module "databricks_security_groups" {
  source                     = "./modules/azure-databricks-security-groups"
  security_group_name_prefix = var.databricks_security_group_prefix
  location                   = var.location
  vnet_resource_group_name   = azurerm_resource_group.rg.name
  private_subnet_id          = module.databricks_subnets.private_subnet_id
  public_subnet_id           = module.databricks_subnets.public_subnet_id
  tags                       = var.databricks_tags
}

module "databricks_workspace" {
  source               = "./modules/azure-databricks-workspace"
  workspace_name       = var.workspace_name
  resource_group_name  = azurerm_resource_group.rg.name
  location             = var.location
  vnet_id              = module.vnet.vnet_id
  private_subnet_name  = module.databricks_subnets.private_subnet_name
  public_subnet_name   = module.databricks_subnets.public_subnet_name
  public_subnet_network_security_group_association_id = module.databricks_security_groups.security_group_public_id
  private_subnet_network_security_group_association_id = module.databricks_security_groups.security_group_private_id
  tags                 = var.databricks_tags
  vnet_name            = var.aks_vnet_name
  depends_on = [module.databricks_subnets, module.databricks_security_groups]
}

resource "azurerm_storage_account" "datalake_storage_account" {
  name                     = var.datalake_storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = var.datalake_account_tier
  account_replication_type = var.datalake_account_replication_type
  account_kind             = var.datalake_account_kind
  is_hns_enabled           = var.datalake_is_hns_enabled
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