# Resource Group & Location
resource_group_name = "rg-sr-dev"
location            = "qatarcentral"
tags = {
  createdWith = "Terraform"
  Environment = "dev"
  Workload    = "Shared Resources"
  Region      = "Qatar Central"
}

# Virtual Network
aks_vnet_name          = "vnet-sr-dev-001"
aks_vnet_address_space = ["192.168.71.0/26"]

# Subnets
vm_subnet_name           = "snet-vm-qatar-001"
vm_subnet_address_prefix = ["192.168.71.0/28"]

pe_subnet_name           = "snet-pe-qatar-001"
pe_subnet_address_prefix = ["192.168.71.16/28"]

# Virtual Machine
vm_name                      = "vm-sr-dev"
vm_count                     = 3
vm_size                      = "Standard_D4s_v3"  #old value Standard_DS1_v2
vm_public_ip                 = false
admin_username               = "azadmin"
# admin_password is not set here so that it is provided at runtime.
vm_os_disk_image             = {
  publisher = "MicrosoftWindowsServer"
  offer     = "WindowsServer"
  sku       = "2022-datacenter-azure-edition"
  version   = "latest"
}
domain_name_label            = "windowsnpcvmtrial"
vm_os_disk_storage_account_type = "StandardSSD_LRS"

# Key Vault
key_vault_name = "kv-sr-dev-01"
# tenant_id is not set here so that it is provided at runtime.
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
public_network_access_enabled = false

# ACR
acr_name                   = "crsrdev01"
acr_admin_enabled          = false
acr_sku                    = "Premium"
acr_georeplication_locations = []

# Databricks Workspace
workspace_name                              = "dbw-sr-dev"
databricks_vnet_resource_group_name           = "rg-sr-dev-001"
databricks_private_subnet_name                = "snet-dbw-dev-qatar-001"
databricks_public_subnet_name                 = "snet-dbw-dev-qatar-002"
public_subnet_address_prefixes                = ["192.168.71.32/28"]
private_subnet_address_prefixes               = ["192.168.71.48/28"]
databricks_security_group_prefix              = "nsg-databricks"
managed_resource_group_name                   = "rg-sr-dev-managed-dbw"
sku_dbw                                       = "premium"

# Datalake Storage
datalake_storage_account_name   = "dlssrdev01"
datalake_account_tier             = "Standard"
datalake_account_replication_type = "LRS"
datalake_account_kind             = "StorageV2"
datalake_is_hns_enabled           = true
datalake_filesystem_name          = "dlsfssrdev"
datalake_filesystem_properties    = {
  hello = "aGVsbG8="
}
