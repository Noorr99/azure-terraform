////////////////////////////////////////////////////////////////////////
// 1. Terraform and Provider
////////////////////////////////////////////////////////////////////////
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.50"
    }
  }
  backend "azurerm" {
    # backend configuration details here (if any)
    resource_group_name  = "RG-QCH-JB-001"
    storage_account_name = "stnihstate001"
    container_name       = "tfstatenihdev"
    key                  = "terraform.tfstate"
    subscription_id      = "751b8a58-5878-4c86-93dc-13c41b3a90cf"
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

////////////////////////////////////////////////////////////////////////
// 2. Resource Group
////////////////////////////////////////////////////////////////////////
/*
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}
*/
data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

////////////////////////////////////////////////////////////////////////
// 3. VNet Module (with Shared + AKS subnets)
////////////////////////////////////////////////////////////////////////
module "vnet" {
  source              = "./modules/virtual_network"
  resource_group_name = var.resource_group_name
  location            = var.location
  vnet_name           = var.aks_vnet_name
  address_space       = var.aks_vnet_address_space

  // Here we add both the Shared Subnet and the new AKS Subnet
  subnets = [
    {
      name                                          = var.shared_subnet_name
      address_prefixes                              = var.shared_subnet_address_prefix
      private_endpoint_network_policies_enabled     = false
      private_link_service_network_policies_enabled = true
    },
    {
      name                  = var.aks_subnet_name
      address_prefixes      = var.aks_subnet_address_prefix
      private_endpoint_network_policies_enabled     = false
      private_link_service_network_policies_enabled = false
    }
  ]
}

////////////////////////////////////////////////////////////////////////
// 4. Data Lake Storage + Private Endpoint + DNS
////////////////////////////////////////////////////////////////////////
resource "azurerm_storage_account" "datalake_storage_account" {
  name                     = var.datalake_storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.datalake_account_tier
  account_replication_type = var.datalake_account_replication_type
  account_kind             = var.datalake_account_kind
  is_hns_enabled           = var.datalake_is_hns_enabled
  tags                     = var.tags
}

module "datalake_private_dns_zone" {
  source                   = "./modules/private_dns_zone"
  name                     = "privatelink.dfs.core.windows.net"
  resource_group_name      = var.resource_group_name
  virtual_networks_to_link = {
    (module.vnet.name) = {
      subscription_id     = data.azurerm_client_config.current.subscription_id
      resource_group_name = var.resource_group_name
    }
  }
  tags = var.tags
}

module "datalake_private_endpoint" {
  source                         = "./modules/private_endpoint"
  name                           = "${azurerm_storage_account.datalake_storage_account.name}-pe"
  location                       = var.location
  resource_group_name            = var.resource_group_name
  subnet_id                      = module.vnet.subnet_ids[var.shared_subnet_name]
  private_connection_resource_id = azurerm_storage_account.datalake_storage_account.id
  subresource_name               = "dfs"
  private_dns_zone_group_name    = "DatalakePrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.datalake_private_dns_zone.id]
  tags                           = var.tags
}

////////////////////////////////////////////////////////////////////////
// 5. Key Vault + Private Endpoint + DNS
////////////////////////////////////////////////////////////////////////
module "key_vault" {
  source              = "./modules/key_vault"
  name                = var.key_vault_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tenant_id           = var.tenant_id            // Provided at runtime
  sku_name            = var.key_vault_sku
  tags                = var.tags

  enabled_for_deployment          = var.key_vault_enabled_for_deployment
  enabled_for_disk_encryption     = var.key_vault_enabled_for_disk_encryption
  enabled_for_template_deployment = var.key_vault_enabled_for_template_deployment
  enable_rbac_authorization       = var.key_vault_enable_rbac_authorization
  purge_protection_enabled        = var.key_vault_purge_protection_enabled
  soft_delete_retention_days      = var.key_vault_soft_delete_retention_days
  public_network_access_enabled   = false

  bypass                     = var.key_vault_bypass
  default_action             = var.key_vault_default_action
  ip_rules                   = var.key_vault_ip_rules
  virtual_network_subnet_ids = []
}

module "keyvault_private_dns_zone" {
  source                   = "./modules/private_dns_zone"
  name                     = "privatelink.vaultcore.azure.net"
  resource_group_name      = var.resource_group_name
  virtual_networks_to_link = {
    (module.vnet.name) = {
      subscription_id     = data.azurerm_client_config.current.subscription_id
      resource_group_name = var.resource_group_name
    }
  }
  tags = var.tags
}

module "keyvault_private_endpoint" {
  source                         = "./modules/private_endpoint"
  name                           = "${var.key_vault_name}-pe"
  location                       = var.location
  resource_group_name            = var.resource_group_name
  subnet_id                      = module.vnet.subnet_ids[var.shared_subnet_name]
  private_connection_resource_id = module.key_vault.id
  subresource_name               = "vault"
  private_dns_zone_group_name    = "KeyVaultPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.keyvault_private_dns_zone.id]
  tags                           = var.tags
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
  subnet_id                = module.vnet.subnet_ids[var.shared_subnet_name]
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
// 7. Data Factory
////////////////////////////////////////////////////////////////////////
module "data_factory" {
  source                     = "./modules/data_factory"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  data_factory_name          = var.data_factory_name
  tags                       = var.tags
  public_network_enabled     = var.public_network_enabled
  data_factory_identity_type = var.data_factory_identity_type
}

////////////////////////////////////////////////////////////////////////
// 8. Route Table for the AKS Subnet (User-Defined Routing)
////////////////////////////////////////////////////////////////////////

module "routetable" {
  source              = "./modules/route_table"
  resource_group_name = var.resource_group_name
  location            = var.location

  route_table_name    = var.route_table_name
  route_name          = var.route_name
  firewall_private_ip = var.firewall_private_ip

  subnets_to_associate = {
    (var.aks_subnet_name) = {
      subscription_id      = data.azurerm_client_config.current.subscription_id
      resource_group_name  = var.resource_group_name
      virtual_network_name = module.vnet.name
    }
  }

}

////////////////////////////////////////////////////////////////////////
// 9. Private DNS Zone for private AKS control plane
////////////////////////////////////////////////////////////////////////
module "aks_private_dns_zone" {
  source              = "./modules/private_dns_zone"
  name                = var.aks_private_dns_zone_name
  resource_group_name = var.resource_group_name
  tags                = var.tags

  virtual_networks_to_link = {
    (module.vnet.name) = {
      subscription_id     = data.azurerm_client_config.current.subscription_id
      resource_group_name = var.resource_group_name
    }
  }
}

////////////////////////////////////////////////////////////////////////
// 10. AKS (Private Cluster) Using the New Subnet
////////////////////////////////////////////////////////////////////////
module "aks_cluster" {
  source = "./modules/aks"

  name                = var.aks_cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  resource_group_id   = data.azurerm_resource_group.rg.id

  kubernetes_version        = var.kubernetes_version
  dns_prefix                = lower(var.aks_cluster_name)
  private_cluster_enabled   = true
  sku_tier                  = var.sku_tier
  automatic_channel_upgrade = var.automatic_channel_upgrade

  // Node pool config
  default_node_pool_name    = var.default_node_pool_name
  default_node_pool_vm_size = var.default_node_pool_vm_size

  // AKS node subnet
  vnet_subnet_id = module.vnet.subnet_ids[var.aks_subnet_name]

  default_node_pool_node_labels            = var.default_node_pool_node_labels
  default_node_pool_enable_auto_scaling    = var.default_node_pool_enable_auto_scaling
  default_node_pool_enable_host_encryption = var.default_node_pool_enable_host_encryption
  default_node_pool_enable_node_public_ip  = var.default_node_pool_enable_node_public_ip
  default_node_pool_max_pods               = var.default_node_pool_max_pods
  default_node_pool_node_count             = var.default_node_pool_node_count
  default_node_pool_os_disk_type           = var.default_node_pool_os_disk_type

  // Networking
  network_plugin         = var.network_plugin
  network_plugin_mode         = var.network_plugin_mode
  outbound_type          = var.outbound_type
  network_service_cidr   = var.network_service_cidr
  network_dns_service_ip = var.network_dns_service_ip

  log_analytics_workspace_id = var.log_analytics_workspace_id

  // RBAC / AAD
  role_based_access_control_enabled = var.role_based_access_control_enabled
  tenant_id                         = var.tenant_id           // Provided at runtime
  admin_group_object_ids            = var.admin_group_object_ids
  azure_rbac_enabled                = var.azure_rbac_enabled

  // AKS node access
  admin_username = var.admin_username
  ssh_public_key = var.ssh_public_key    // Provided at runtime

  // Add-ons
  keda_enabled                     = var.keda_enabled
  vertical_pod_autoscaler_enabled  = var.vertical_pod_autoscaler_enabled
  workload_identity_enabled        = var.workload_identity_enabled
  oidc_issuer_enabled              = var.oidc_issuer_enabled
  open_service_mesh_enabled        = var.open_service_mesh_enabled
  image_cleaner_enabled            = var.image_cleaner_enabled
  azure_policy_enabled             = var.azure_policy_enabled
  http_application_routing_enabled = var.http_application_routing_enabled

  tags = var.tags

  depends_on = [
    module.routetable,
    module.aks_private_dns_zone
  ]
}

////////////////////////////////////////////////////////////////////////
// 11. (Optional) Role Assignment: Network Contributor
//     Grants the AKS user-assigned identity permission to manage net resources
////////////////////////////////////////////////////////////////////////
resource "azurerm_role_assignment" "aks_network_contributor" {
  scope                            = data.azurerm_resource_group.rg.id
  role_definition_name             = "Network Contributor"
  principal_id                     = module.aks_cluster.aks_identity_principal_id
  skip_service_principal_aad_check = true
}
