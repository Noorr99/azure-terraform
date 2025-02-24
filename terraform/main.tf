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
    resource_group_name  = "rg-terraform-storage"
    storage_account_name = "terraformstgaks99"
    container_name       = "tfstatecensus"
    key                  = "terraform.tfstate"
    subscription_id      = "3e169b7b-edb6-4452-94b0-847f2917971a"
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
// 3. VNet Module (with Shared + Secondary subnets)
////////////////////////////////////////////////////////////////////////
module "vnet" {
  source              = "./modules/virtual_network"
  resource_group_name = var.resource_group_name
  location            = var.location
  vnet_name           = var.vnet_name
  address_space       = var.vnet_address_space

  // Add both the Shared Subnet and the Secondary Subnet
  subnets = [
    {
      name                                          = var.shared_subnet_name
      address_prefixes                              = var.shared_subnet_address_prefix
      private_endpoint_network_policies_enabled     = false
      private_link_service_network_policies_enabled = true
    },
    {
      name                  = var.secondary_subnet_name
      address_prefixes      = var.secondary_subnet_address_prefix
      private_endpoint_network_policies_enabled     = false
      private_link_service_network_policies_enabled = false
    }
  ]
}

////////////////////////////////////////////////////////////////////////
// 4. Key Vault + Private Endpoint + DNS
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
// 5. Data Factory + Private Endpoint + DNS
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

module "datafactory_private_dns_zone" {
  source                   = "./modules/private_dns_zone"
  name                     = "privatelink.datafactory.azure.net"
  resource_group_name      = var.resource_group_name
  virtual_networks_to_link = {
    (module.vnet.name) = {
      subscription_id     = data.azurerm_client_config.current.subscription_id
      resource_group_name = var.resource_group_name
    }
  }
  tags = var.tags
}

module "datafactory_private_endpoint" {
  source                         = "./modules/private_endpoint"
  name                           = "${var.data_factory_name}-pe"
  location                       = var.location
  resource_group_name            = var.resource_group_name
  subnet_id                      = module.vnet.subnet_ids[var.shared_subnet_name]
  private_connection_resource_id = module.data_factory.id
  subresource_name               = "dataFactory"
  private_dns_zone_group_name    = "DataFactoryPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.datafactory_private_dns_zone.id]
  tags                           = var.tags
}

////////////////////////////////////////////////////////////////////////
// 6. Cognitive Service + Private Endpoint + DNS
////////////////////////////////////////////////////////////////////////
resource "azurerm_cognitive_account" "cognitive_service" {
  name                = var.cognitive_service_name
  resource_group_name = var.resource_group_name
  location            = var.location
  kind                = var.cognitive_service_kind    // e.g., "CognitiveServices"
  sku_name            = var.cognitive_service_sku     // e.g., "S0" or "F0"
  tags                = var.tags

  public_network_access_enabled = var.cognitive_public_network_access_enabled
}

module "cognitive_dns_zone" {
  source                   = "./modules/private_dns_zone"
  name                     = "privatelink.cognitiveservices.azure.com"
  resource_group_name      = var.resource_group_name
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
  name                           = "${var.cognitive_service_name}-pe"
  location                       = var.location
  resource_group_name            = var.resource_group_name
  subnet_id                      = module.vnet.subnet_ids[var.shared_subnet_name]
  private_connection_resource_id = azurerm_cognitive_account.cognitive_service.id
  subresource_name               = "cognitiveServices"
  private_dns_zone_group_name    = "CognitivePrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.cognitive_dns_zone.id]
  tags                           = var.tags
}