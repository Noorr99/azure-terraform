# Resource Group & Location
resource_group_name = "rg-census-dev-001"
location            = "qatarcentral"
tags = {
  createdWith = "Terraform"
  Environment = "dev"
  Workload    = "census"
  Region      = "Qatar Central"
}

# Virtual Network
vnet_name          = "vnet-dev-qatar-001"
vnet_address_space = ["172.40.0.128/26"]

# Shared Subnet (for SQL, Key Vault, Data Lake)
shared_subnet_name           = "snet-census-pe-qatar-001"
shared_subnet_address_prefix = ["172.40.0.128/27"]

# Secondary Subnet Free
secondary_subnet_name           = "snet-census-secondary-qatar-001"
secondary_subnet_address_prefix = ["172.40.0.160/27"]

# Key Vault
key_vault_name = "kv-census-dev-001"
key_vault_sku  = "standard"
key_vault_enabled_for_deployment          = false
key_vault_enabled_for_disk_encryption     = false
key_vault_enabled_for_template_deployment = false
key_vault_enable_rbac_authorization       = false
key_vault_purge_protection_enabled        = false
key_vault_soft_delete_retention_days      = 30
key_vault_bypass           = "AzureServices"
key_vault_default_action   = "Allow"
key_vault_ip_rules         = []

# Data Factory
data_factory_name          = "adf-census-dev"
public_network_enabled     = false
data_factory_identity_type = "SystemAssigned"

/*
# Cognitive Service
cognitive_service_name = "cv-census-dev-001"  // "cog-customvision-dev-001"
cognitive_service_kind = "ComputerVision"    // Was "CognitiveServices"
cognitive_service_sku  = "S0"
cognitive_public_network_access_enabled = false
cognitive_custom_subdomain_name =  "cvcustomsubdomain"// "cogcustomsubdomain"  # Adjust to a unique value in your region.
*/
# (Optional) Log Analytics Workspace
log_analytics_workspace_id = null
