# Resource Group & Location
resource_group_name = "rg-census-dev-001"
location            = "qatarcentral"
tags = {
  createdWith = "Terraform"
  Environment = "dev"
  Workload    = "nih"
  Region      = "Qatar Central"
}

# Virtual Network
vnet_name          = "vnet-dev-qatar-001"
vnet_address_space = ["192.168.71.128/26"]

# Shared Subnet (for SQL, Key Vault, Data Lake)
shared_subnet_name           = "snet-nih-pe-qatar-001"
shared_subnet_address_prefix = ["192.168.71.128/28"]

# Secondary Subnet
secondary_subnet_name           = "snet-nih-secondary-qatar-001"
secondary_subnet_address_prefix = ["192.168.71.160/27"]

# Key Vault
key_vault_name = "kv-noor-dev-001"
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
data_factory_name          = "adf-noor-dev"
public_network_enabled     = false
data_factory_identity_type = "SystemAssigned"

# Cognitive Service
cognitive_service_kind = "CustomVision.Training"
cognitive_service_sku  = "S0"
cognitive_public_network_access_enabled = false

# (Optional) Log Analytics Workspace
log_analytics_workspace_id = null
