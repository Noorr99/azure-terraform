terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.50"
    }
  }
}

provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    # backend configuration here
  }
}

locals {
  storage_account_prefix = "boot"
  route_table_name       = "DefaultRouteTable"
  route_name             = "RouteToAzureFirewall"
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "log_analytics_workspace" {
  source                  = "./modules/log_analytics"
  name                    = var.log_analytics_workspace_name
  location                = var.location
  resource_group_name     = azurerm_resource_group.rg.name
  solution_plan_map       = var.solution_plan_map
}

module "hub_network" {
  source                     = "./modules/virtual_network"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = var.location
  vnet_name                  = var.hub_vnet_name
  address_space              = var.hub_address_space
  tags                       = var.tags
  log_analytics_workspace_id = module.log_analytics_workspace.id

  subnets = [
    {
      name                                  = "AzureFirewallSubnet"
      address_prefixes                      = var.hub_firewall_subnet_address_prefix
      private_endpoint_network_policies_enabled = true
      private_link_service_network_policies_enabled = false
    },
    {
      name                                  = "AzureBastionSubnet"
      address_prefixes                      = var.hub_bastion_subnet_address_prefix
      private_endpoint_network_policies_enabled = true
      private_link_service_network_policies_enabled = false
    }
  ]
}

module "aks_network" {
  source                     = "./modules/virtual_network"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = var.location
  vnet_name                  = var.aks_vnet_name
  address_space              = var.aks_vnet_address_space
  log_analytics_workspace_id = module.log_analytics_workspace.id

  subnets = [
    {
      name                                  = var.default_node_pool_subnet_name
      address_prefixes                      = var.default_node_pool_subnet_address_prefix
      private_endpoint_network_policies_enabled = true
      private_link_service_network_policies_enabled = false
    },
    {
      name                                  = var.additional_node_pool_subnet_name
      address_prefixes                      = var.additional_node_pool_subnet_address_prefix
      private_endpoint_network_policies_enabled = true
      private_link_service_network_policies_enabled = false
    },
    {
      name                                  = var.pod_subnet_name
      address_prefixes                      = var.pod_subnet_address_prefix
      private_endpoint_network_policies_enabled = true
      private_link_service_network_policies_enabled = false
    },
    {
      name                                  = var.vm_subnet_name
      address_prefixes                      = var.vm_subnet_address_prefix
      private_endpoint_network_policies_enabled = true
      private_link_service_network_policies_enabled = false
    }
  ]
}

#############################
# Commented-out modules not needed for now
#############################

# module "vnet_peering" {
#   source              = "./modules/virtual_network_peering"
#   vnet_1_name         = var.hub_vnet_name
#   vnet_1_id           = module.hub_network.vnet_id
#   vnet_1_rg           = azurerm_resource_group.rg.name
#   vnet_2_name         = var.aks_vnet_name
#   vnet_2_id           = module.aks_network.vnet_id
#   vnet_2_rg           = azurerm_resource_group.rg.name
#   peering_name_1_to_2 = "${var.hub_vnet_name}To${var.aks_vnet_name}"
#   peering_name_2_to_1 = "${var.aks_vnet_name}To${var.hub_vnet_name}"
# }

# module "firewall" {
#   source                     = "./modules/firewall"
#   name                       = var.firewall_name
#   resource_group_name        = azurerm_resource_group.rg.name
#   zones                      = var.firewall_zones
#   threat_intel_mode          = var.firewall_threat_intel_mode
#   location                   = var.location
#   sku_name                   = var.firewall_sku_name 
#   sku_tier                   = var.firewall_sku_tier
#   pip_name                   = "${var.firewall_name}PublicIp"
#   subnet_id                  = module.hub_network.subnet_ids["AzureFirewallSubnet"]
#   log_analytics_workspace_id = module.log_analytics_workspace.id
# }

# module "routetable" {
#   source               = "./modules/route_table"
#   resource_group_name  = azurerm_resource_group.rg.name
#   location             = var.location
#   route_table_name     = local.route_table_name
#   route_name           = local.route_name
#   firewall_private_ip  = module.firewall.private_ip_address
#   subnets_to_associate = {
#     (var.default_node_pool_subnet_name) = {
#       subscription_id      = data.azurerm_client_config.current.subscription_id
#       resource_group_name  = azurerm_resource_group.rg.name
#       virtual_network_name = module.aks_network.name
#     }
#     (var.additional_node_pool_subnet_name) = {
#       subscription_id      = data.azurerm_client_config.current.subscription_id
#       resource_group_name  = azurerm_resource_group.rg.name
#       virtual_network_name = module.aks_network.name
#     }
#   }
# }

#############################
# End of commented-out modules
#############################

module "container_registry" {
  source                     = "./modules/container_registry"
  name                       = var.acr_name
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = var.location
  sku                        = var.acr_sku
  admin_enabled              = var.acr_admin_enabled
  georeplication_locations   = var.acr_georeplication_locations
  log_analytics_workspace_id = module.log_analytics_workspace.id
}

# The following AKS cluster module is commented out since provisioning an AKS cluster is not
# required for our current deployment (which focuses on a VM)
#
# module "aks_cluster" {
#   source                      = "./modules/aks"
#   name                        = var.aks_cluster_name
#   location                    = var.location
#   resource_group_name         = azurerm_resource_group.rg.name
#   resource_group_id           = azurerm_resource_group.rg.id
#   kubernetes_version          = var.kubernetes_version
#   dns_prefix                  = lower(var.aks_cluster_name)
#   private_cluster_enabled     = true
#   automatic_channel_upgrade   = var.automatic_channel_upgrade
#   sku_tier                    = var.sku_tier
#   default_node_pool_name      = var.default_node_pool_name
#   default_node_pool_vm_size   = var.default_node_pool_vm_size
#   vnet_subnet_id              = module.aks_network.subnet_ids[var.default_node_pool_subnet_name]
#   default_node_pool_availability_zones = var.default_node_pool_availability_zones
#   default_node_pool_node_labels         = var.default_node_pool_node_labels
#   default_node_pool_node_taints         = var.default_node_pool_node_taints
#   default_node_pool_enable_auto_scaling  = var.default_node_pool_enable_auto_scaling
#   default_node_pool_enable_host_encryption = var.default_node_pool_enable_host_encryption
#   default_node_pool_enable_node_public_ip   = var.default_node_pool_enable_node_public_ip
#   default_node_pool_max_pods           = var.default_node_pool_max_pods
#   default_node_pool_max_count          = var.default_node_pool_max_count
#   default_node_pool_min_count          = var.default_node_pool_min_count
#   default_node_pool_node_count         = var.default_node_pool_node_count
#   default_node_pool_os_disk_type       = var.default_node_pool_os_disk_type
#   tags                                 = var.tags
#   network_dns_service_ip               = var.network_dns_service_ip
#   network_plugin                       = var.network_plugin
#   outbound_type                        = "userDefinedRouting"
#   network_service_cidr                 = var.network_service_cidr
#   log_analytics_workspace_id           = module.log_analytics_workspace.id
#   role_based_access_control_enabled    = var.role_based_access_control_enabled
#   tenant_id                            = data.azurerm_client_config.current.tenant_id
#   admin_group_object_ids               = var.admin_group_object_ids
#   azure_rbac_enabled                   = var.azure_rbac_enabled
#   admin_username                       = var.admin_username
#   ssh_public_key                       = var.ssh_public_key
#   keda_enabled                         = var.keda_enabled
#   vertical_pod_autoscaler_enabled      = var.vertical_pod_autoscaler_enabled
#   workload_identity_enabled            = var.workload_identity_enabled
#   oidc_issuer_enabled                  = var.oidc_issuer_enabled
#   open_service_mesh_enabled            = var.open_service_mesh_enabled
#   image_cleaner_enabled                = var.image_cleaner_enabled
#   azure_policy_enabled                 = var.azure_policy_enabled
#   http_application_routing_enabled     = var.http_application_routing_enabled
#
#   depends_on                           = [module.routetable]
# }

# Role assignments for an AKS cluster are not required at this time.
#
# resource "azurerm_role_assignment" "network_contributor" {
#   scope                = azurerm_resource_group.rg.id
#   role_definition_name = "Network Contributor"
#   principal_id         = module.aks_cluster.aks_identity_principal_id
#   skip_service_principal_aad_check = true
# }
#
# resource "azurerm_role_assignment" "acr_pull" {
#   role_definition_name = "AcrPull"
#   scope                = module.container_registry.id
#   principal_id         = module.aks_cluster.kubelet_identity_object_id
#   skip_service_principal_aad_check = true
# }

# Generate random string to help create a unique storage account name (for Data Lake or boot diagnostics)
resource "random_string" "storage_account_suffix" {
  length  = 8
  special = false
  lower   = true
  upper   = false
  numeric = false
}

# Provision a Storage Account which can be used as Data Lake Storage if needed.
module "storage_account" {
  source               = "./modules/storage_account"
  name                 = "${local.storage_account_prefix}${random_string.storage_account_suffix.result}"
  location             = var.location
  resource_group_name  = azurerm_resource_group.rg.name
  account_kind         = var.storage_account_kind
  account_tier         = var.storage_account_tier
  replication_type     = var.storage_account_replication_type
}

# Provision the Virtual Machine.
module "virtual_machine" {
  source                              = "./modules/virtual_machine"
  name                                = var.vm_name
  size                                = var.vm_size
  location                            = var.location
  public_ip                           = var.vm_public_ip
  vm_user                             = var.admin_username
  admin_ssh_public_key                = var.ssh_public_key
  os_disk_image                       = var.vm_os_disk_image
  domain_name_label                   = var.domain_name_label
  resource_group_name                 = azurerm_resource_group.rg.name
  subnet_id                           = module.aks_network.subnet_ids[var.vm_subnet_name]
  os_disk_storage_account_type        = var.vm_os_disk_storage_account_type
  boot_diagnostics_storage_account    = module.storage_account.primary_blob_endpoint
  log_analytics_workspace_id          = module.log_analytics_workspace.workspace_id
  log_analytics_workspace_key         = module.log_analytics_workspace.primary_shared_key
  log_analytics_workspace_resource_id = module.log_analytics_workspace.id
  script_storage_account_name         = var.script_storage_account_name
  script_storage_account_key          = var.script_storage_account_key
  container_name                      = var.container_name
  script_name                         = var.script_name
}

# Provision the Key Vault.
module "key_vault" {
  source                          = "./modules/key_vault"
  name                            = var.key_vault_name
  location                        = var.location
  resource_group_name             = azurerm_resource_group.rg.name
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = var.key_vault_sku_name
  tags                            = var.tags
  enabled_for_deployment          = var.key_vault_enabled_for_deployment
  enabled_for_disk_encryption     = var.key_vault_enabled_for_disk_encryption
  enabled_for_template_deployment = var.key_vault_enabled_for_template_deployment
  enable_rbac_authorization       = var.key_vault_enable_rbac_authorization
  purge_protection_enabled        = var.key_vault_purge_protection_enabled
  soft_delete_retention_days      = var.key_vault_soft_delete_retention_days
  bypass                          = var.key_vault_bypass
  default_action                  = var.key_vault_default_action
  log_analytics_workspace_id      = module.log_analytics_workspace.id
}

# Create a Private DNS Zone for the Container Registry.
module "acr_private_dns_zone" {
  source                = "./modules/private_dns_zone"
  name                  = "privatelink.azurecr.io"
  resource_group_name   = azurerm_resource_group.rg.name
  virtual_networks_to_link = {
    (module.hub_network.name) = {
      subscription_id     = data.azurerm_client_config.current.subscription_id
      resource_group_name = azurerm_resource_group.rg.name
    }
    (module.aks_network.name) = {
      subscription_id     = data.azurerm_client_config.current.subscription_id
      resource_group_name = azurerm_resource_group.rg.name
    }
  }
}

# Create a Private DNS Zone for the Key Vault.
module "key_vault_private_dns_zone" {
  source                = "./modules/private_dns_zone"
  name                  = "privatelink.vaultcore.azure.net"
  resource_group_name   = azurerm_resource_group.rg.name
  virtual_networks_to_link = {
    (module.hub_network.name) = {
      subscription_id     = data.azurerm_client_config.current.subscription_id
      resource_group_name = azurerm_resource_group.rg.name
    }
    (module.aks_network.name) = {
      subscription_id     = data.azurerm_client_config.current.subscription_id
      resource_group_name = azurerm_resource_group.rg.name
    }
  }
}

# Create a Private Endpoint for the Container Registry (ACR).
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

# Create a Private Endpoint for the Key Vault.
module "key_vault_private_endpoint" {
  source                         = "./modules/private_endpoint"
  name                           = "${title(module.key_vault.name)}PrivateEndpoint"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.rg.name
  subnet_id                      = module.aks_network.subnet_ids[var.vm_subnet_name]
  tags                           = var.tags
  private_connection_resource_id = module.key_vault.id
  is_manual_connection           = false
  subresource_name               = "vault"
  private_dns_zone_group_name    = "KeyVaultPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.key_vault_private_dns_zone.id]
}

#############################
# Optionally, if you need private endpoints for storage (Data Lake / Blob), you can enable the following:
#############################

# module "blob_private_dns_zone" {
#   source                = "./modules/private_dns_zone"
#   name                  = "privatelink.blob.core.windows.net"
#   resource_group_name   = azurerm_resource_group.rg.name
#   virtual_networks_to_link = {
#     (module.hub_network.name) = {
#       subscription_id     = data.azurerm_client_config.current.subscription_id
#       resource_group_name = azurerm_resource_group.rg.name
#     }
#     (module.aks_network.name) = {
#       subscription_id     = data.azurerm_client_config.current.subscription_id
#       resource_group_name = azurerm_resource_group.rg.name
#     }
#   }
# }
#
# module "blob_private_endpoint" {
#   source                         = "./modules/private_endpoint"
#   name                           = "${title(module.storage_account.name)}PrivateEndpoint"
#   location                       = var.location
#   resource_group_name            = azurerm_resource_group.rg.name
#   subnet_id                      = module.aks_network.subnet_ids[var.vm_subnet_name]
#   tags                           = var.tags
#   private_connection_resource_id = module.storage_account.id
#   is_manual_connection           = false
#   subresource_name               = "blob"
#   private_dns_zone_group_name    = "BlobPrivateDnsZoneGroup"
#   private_dns_zone_group_ids     = [module.blob_private_dns_zone.id]
# }
