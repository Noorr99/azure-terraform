////////////////////////////////////////////////////////////////////////
//                       Terraform Settings
////////////////////////////////////////////////////////////////////////
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = var.azure_provider_version
    }
  }

  backend "azurerm" {
    resource_group_name  = var.backend_resource_group_name
    storage_account_name = var.backend_storage_account_name
    container_name       = var.backend_container_name
    key                  = var.backend_key
  }
}

provider "azurerm" {
  features {}
  # Optionally define subscription_id, tenant_id, client_id, etc.
}

////////////////////////////////////////////////////////////////////////
//                         Resource Group
////////////////////////////////////////////////////////////////////////
resource "azurerm_resource_group" "rg" {
  # CHANGED: name = var.resource_group_name
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

////////////////////////////////////////////////////////////////////////
//                       Virtual Network Module
////////////////////////////////////////////////////////////////////////
module "vnet" {
  source              = "./modules/virtual_network"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  # CHANGED: vnet_name = var.vnet_name
  vnet_name           = var.vnet_name
  address_space       = var.vnet_address_space

  # Creating two subnets:
  # 1. For VMs
  # 2. For Private Endpoints (KV, ACR, Data Lake, etc.)
  subnets = [
    {
      # CHANGED: name = var.vm_subnet_name
      name                                          = var.vm_subnet_name
      address_prefixes                              = var.vm_subnet_address_prefix
      private_endpoint_network_policies_enabled     = true
      private_link_service_network_policies_enabled = false
    },
    {
      # CHANGED: name = var.pe_subnet_name
      name                                          = var.pe_subnet_name
      address_prefixes                              = var.pe_subnet_address_prefix
      private_endpoint_network_policies_enabled     = false
      private_link_service_network_policies_enabled = true
    }
  ]
}

////////////////////////////////////////////////////////////////////////
//                       Virtual Machine Module
////////////////////////////////////////////////////////////////////////
module "virtual_machine" {
  count  = var.vm_count
  source = "./modules/virtual_machine"

  # CHANGED: name = "${var.vm_name_prefix}-${count.index + 1}"
  name                = "${var.vm_name_prefix}-${count.index + 1}"
  size                = var.vm_size
  location            = var.location
  public_ip           = var.vm_public_ip
  vm_user             = var.admin_username
  admin_password      = var.admin_password
  os_disk_image       = var.vm_os_disk_image
  domain_name_label   = var.domain_name_label
  resource_group_name = azurerm_resource_group.rg.name

  # CHANGED: subnet_id = module.vnet.subnet_ids[var.vm_subnet_name]
  subnet_id = module.vnet.subnet_ids[var.vm_subnet_name]

  os_disk_storage_account_type = var.vm_os_disk_storage_account_type
}

////////////////////////////////////////////////////////////////////////
//                       Key Vault Module
////////////////////////////////////////////////////////////////////////
module "key_vault" {
  source              = "./modules/key_vault"
  # CHANGED: name = var.key_vault_name
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

  bypass         = var.key_vault_bypass
  default_action = var.key_vault_default_action
  ip_rules       = var.key_vault_ip_rules
}

# The key_vault module should have:
# public_network_access_enabled = false

////////////////////////////////////////////////////////////////////////
//                  Key Vault Private DNS & Private Endpoint
////////////////////////////////////////////////////////////////////////
module "keyvault_private_dns_zone" {
  source                = "./modules/private_dns_zone"
  name                  = "privatelink.vaultcore.azure.net"
  resource_group_name   = azurerm_resource_group.rg.name

  virtual_networks_to_link = {
    (module.vnet.name) = {
      subscription_id     = data.azurerm_client_config.current.subscription_id
      resource_group_name = azurerm_resource_group.rg.name
    }
  }

  tags = var.tags
}

module "keyvault_private_endpoint" {
  source                         = "./modules/private_endpoint"
  # CHANGED: name = "${module.key_vault.name}PrivateEndpoint"
  name                           = "${module.key_vault.name}PrivateEndpoint"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.rg.name

  # CHANGED: subnet_id = module.vnet.subnet_ids[var.pe_subnet_name]
  subnet_id                      = module.vnet.subnet_ids[var.pe_subnet_name]
  tags                           = var.tags
  private_connection_resource_id = module.key_vault.id
  is_manual_connection           = false
  subresource_name               = "vault"
  private_dns_zone_group_name    = "KeyVaultPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.keyvault_private_dns_zone.id]
}

////////////////////////////////////////////////////////////////////////
//                          ACR Module
////////////////////////////////////////////////////////////////////////
module "acr" {
  source              = "./modules/container_registry"
  # CHANGED: name = var.acr_name
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  admin_enabled       = var.acr_admin_enabled
  sku                 = var.acr_sku
  tags                = var.tags

  georeplication_locations = var.acr_georeplication_locations
}

# The container_registry module should have:
# public_network_access_enabled = false
# network_rule_set { default_action = "Deny" }

////////////////////////////////////////////////////////////////////////
//               ACR Private DNS & Private Endpoint
////////////////////////////////////////////////////////////////////////
module "acr_private_dns_zone" {
  source                = "./modules/private_dns_zone"
  name                  = "privatelink.azurecr.io"
  resource_group_name   = azurerm_resource_group.rg.name

  virtual_networks_to_link = {
    (module.vnet.name) = {
      subscription_id     = data.azurerm_client_config.current.subscription_id
      resource_group_name = azurerm_resource_group.rg.name
    }
  }

  tags = var.tags
}

module "acr_private_endpoint" {
  source                         = "./modules/private_endpoint"
  # CHANGED: name = "${module.acr.name}PrivateEndpoint"
  name                           = "${module.acr.name}PrivateEndpoint"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.rg.name

  # CHANGED: subnet_id = module.vnet.subnet_ids[var.pe_subnet_name]
  subnet_id                      = module.vnet.subnet_ids[var.pe_subnet_name]
  tags                           = var.tags
  private_connection_resource_id = module.acr.id
  is_manual_connection           = false
  subresource_name               = "registry"
  private_dns_zone_group_name    = "AcrPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.acr_private_dns_zone.id]
}

////////////////////////////////////////////////////////////////////////
//                     Databricks Subnets Module
////////////////////////////////////////////////////////////////////////
module "databricks_subnets" {
  source                          = "./modules/azure-databricks-subnets"
  subnet_name_prefix              = "databricks"

  # If you previously used local.vnet_name, just do:
  vnet_name                       = var.vnet_name
  vnet_resource_group_name        = azurerm_resource_group.rg.name
  private_subnet_address_prefixes = var.databricks_private_subnet_address_prefixes
  public_subnet_address_prefixes  = var.databricks_public_subnet_address_prefixes
  service_delegation_actions      = var.databricks_service_delegation_actions
  additional_service_endpoints    = var.databricks_additional_service_endpoints
  tags                            = var.databricks_tags
}

////////////////////////////////////////////////////////////////////////
//                 Databricks Security Groups Module
////////////////////////////////////////////////////////////////////////
module "databricks_security_groups" {
  source                     = "./modules/azure-databricks-security-groups"
  security_group_name_prefix = var.databricks_security_group_prefix
  location                   = var.location
  vnet_resource_group_name   = azurerm_resource_group.rg.name
  private_subnet_id          = module.databricks_subnets.private_subnet_id
  public_subnet_id           = module.databricks_subnets.public_subnet_id
  tags                       = var.databricks_tags
}

////////////////////////////////////////////////////////////////////////
//                   Databricks Workspace Module
////////////////////////////////////////////////////////////////////////
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
  vnet_name            = var.vnet_name

  depends_on = [
    module.databricks_subnets,
    module.databricks_security_groups
  ]
}

////////////////////////////////////////////////////////////////////////
//                 Data Lake Storage Account & File System
////////////////////////////////////////////////////////////////////////
data "azurerm_client_config" "current" {}

resource "azurerm_storage_account" "datalake_storage_account" {
  # CHANGED: name = var.datalake_storage_account_name
  name                     = var.datalake_storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = var.datalake_account_tier
  account_replication_type = var.datalake_account_replication_type
  account_kind             = var.datalake_account_kind
  is_hns_enabled           = var.datalake_is_hns_enabled
}

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
  properties         = var.datalake_filesystem_properties

  depends_on = [
    azurerm_storage_account.datalake_storage_account,
    time_sleep.role_assignment_sleep
  ]
}

////////////////////////////////////////////////////////////////////////
//                     Data Lake Private Endpoint
////////////////////////////////////////////////////////////////////////
module "datalake_private_dns_zone" {
  source                = "./modules/private_dns_zone"
  name                  = "privatelink.dfs.core.windows.net"
  resource_group_name   = azurerm_resource_group.rg.name

  virtual_networks_to_link = {
    (module.vnet.name) = {
      subscription_id     = data.azurerm_client_config.current.subscription_id
      resource_group_name = azurerm_resource_group.rg.name
    }
  }

  tags = var.tags
}

module "datalake_private_endpoint" {
  source                         = "./modules/private_endpoint"
  # CHANGED: name = "${azurerm_storage_account.datalake_storage_account.name}PrivateEndpoint"
  name                           = "${azurerm_storage_account.datalake_storage_account.name}PrivateEndpoint"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.rg.name

  # CHANGED: subnet_id = module.vnet.subnet_ids[var.pe_subnet_name]
  subnet_id                      = module.vnet.subnet_ids[var.pe_subnet_name]
  tags                           = var.tags
  private_connection_resource_id = azurerm_storage_account.datalake_storage_account.id
  is_manual_connection           = false
  subresource_name               = "dfs"
  private_dns_zone_group_name    = "DatalakePrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.datalake_private_dns_zone.id]
}
