///////////////////////////////////////////////////////////
// 1. Terraform & Provider
///////////////////////////////////////////////////////////
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.50"
    }
  }

  # Uncomment if using remote state, etc.
  # backend "azurerm" {
  #   ...
  # }
}

provider "azurerm" {
  features {}
}

///////////////////////////////////////////////////////////
// 2. Resource Group & Config
///////////////////////////////////////////////////////////
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

data "azurerm_client_config" "current" {}

///////////////////////////////////////////////////////////
// 3. Virtual Network & Subnets
//    Creates two subnets: "snet-shared" and "snet-aks"
///////////////////////////////////////////////////////////
module "vnet" {
  source              = "./modules/virtual_network"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  vnet_name           = "vnet-nih-dev-002"
  address_space       = ["10.0.0.0/16"]

  subnets = [
    {
      name                                          = var.shared_subnet_name
      address_prefixes                              = var.shared_subnet_address_prefix
      private_endpoint_network_policies_enabled     = false
      private_link_service_network_policies_enabled = true
    },
    {
      name                                          = var.aks_subnet_name
      address_prefixes                              = var.aks_subnet_address_prefix
      private_endpoint_network_policies_enabled     = false
      private_link_service_network_policies_enabled = false
    }
  ]
}

///////////////////////////////////////////////////////////
// 4. Route Table (UDR)
//    Associates with the AKS subnet for userDefinedRouting.
///////////////////////////////////////////////////////////
module "routetable" {
  source              = "./modules/route_table"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  // Provide any param your module requires:
  route_table_name    = var.route_table_name
  route_name          = var.route_name

  // The IP of your NVA/Firewall for default route
  firewall_private_ip = var.firewall_private_ip

  // Associate route table with the new AKS subnet
  subnets_to_associate = {
    (var.aks_subnet_name) = {
      subscription_id      = data.azurerm_client_config.current.subscription_id
      resource_group_name  = azurerm_resource_group.rg.name
      virtual_network_name = module.vnet.name
    }
  }
}

///////////////////////////////////////////////////////////
// 5. Private DNS Zone for Private AKS
//    For private_cluster_enabled = true, we link
//    'privatelink.<region>.azmk8s.io' to our VNet
///////////////////////////////////////////////////////////
module "aks_private_dns_zone" {
  source              = "./modules/private_dns_zone"
  name                = var.aks_private_dns_zone_name
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags

  // Link your VNet so the cluster's private FQDN resolves
  virtual_networks_to_link = {
    (module.vnet.name) = {
      subscription_id     = data.azurerm_client_config.current.subscription_id
      resource_group_name = azurerm_resource_group.rg.name
    }
  }
}

///////////////////////////////////////////////////////////
// 6. AKS Module - Private Cluster using the new AKS subnet
///////////////////////////////////////////////////////////
module "aks_cluster" {
  source                               = "./modules/aks"

  name                                 = var.aks_cluster_name
  location                             = var.location
  resource_group_name                  = azurerm_resource_group.rg.name
  resource_group_id                    = azurerm_resource_group.rg.id
  kubernetes_version                   = var.kubernetes_version
  dns_prefix                           = lower(var.aks_cluster_name)

  // Enable private cluster
  private_cluster_enabled              = true
  sku_tier                             = var.sku_tier
  automatic_channel_upgrade            = var.automatic_channel_upgrade

  // Node pool config
  default_node_pool_name              = var.default_node_pool_name
  default_node_pool_vm_size           = var.default_node_pool_vm_size
  vnet_subnet_id                       = module.vnet.subnet_ids[var.aks_subnet_name]

  default_node_pool_availability_zones     = var.default_node_pool_availability_zones
  default_node_pool_node_labels            = var.default_node_pool_node_labels
  default_node_pool_node_taints            = var.default_node_pool_node_taints
  default_node_pool_enable_auto_scaling    = var.default_node_pool_enable_auto_scaling
  default_node_pool_enable_host_encryption = var.default_node_pool_enable_host_encryption
  default_node_pool_enable_node_public_ip  = var.default_node_pool_enable_node_public_ip
  default_node_pool_max_pods               = var.default_node_pool_max_pods
  default_node_pool_max_count              = var.default_node_pool_max_count
  default_node_pool_min_count              = var.default_node_pool_min_count
  default_node_pool_node_count             = var.default_node_pool_node_count
  default_node_pool_os_disk_type           = var.default_node_pool_os_disk_type

  // Networking
  network_plugin         = var.network_plugin
  outbound_type          = var.outbound_type
  network_service_cidr   = var.network_service_cidr
  network_dns_service_ip = var.network_dns_service_ip
  
  // No log analytics for now
  log_analytics_workspace_id = var.log_analytics_workspace_id

  // AAD / RBAC
  role_based_access_control_enabled = var.role_based_access_control_enabled
  tenant_id                         = var.tenant_id
  admin_group_object_ids            = var.admin_group_object_ids
  azure_rbac_enabled               = var.azure_rbac_enabled

  // Node access
  admin_username = var.admin_username
  ssh_public_key = var.ssh_public_key

  // Add-ons
  keda_enabled                      = var.keda_enabled
  vertical_pod_autoscaler_enabled  = var.vertical_pod_autoscaler_enabled
  workload_identity_enabled         = var.workload_identity_enabled
  oidc_issuer_enabled              = var.oidc_issuer_enabled
  open_service_mesh_enabled        = var.open_service_mesh_enabled
  image_cleaner_enabled            = var.image_cleaner_enabled
  azure_policy_enabled             = var.azure_policy_enabled
  http_application_routing_enabled = var.http_application_routing_enabled

  tags = var.tags

  depends_on = [
    module.routetable,          // Ensure route table is created/associated
    module.aks_private_dns_zone // Ensure private DNS zone is ready
  ]
}

///////////////////////////////////////////////////////////
// 7. (Optional) Role Assignments
//    Grant AKS identity "Network Contributor" on the RG
//    if your module uses a User Assigned Identity
///////////////////////////////////////////////////////////
resource "azurerm_role_assignment" "aks_network_contributor" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Network Contributor"
  // This principal_id typically comes from the AKS module output
  // e.g. module.aks_cluster.aks_identity_principal_id
  principal_id         = module.aks_cluster.aks_identity_principal_id

  skip_service_principal_aad_check = true
}
