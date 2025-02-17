# Resource Group & Location
resource_group_name = "rg-sr-uat"
location            = "qatarcentral"
tags = {
  createdWith = "Terraform"
  Environment = "uat"
  Workload    = "Shared Resources"
  Region      = "Qatar Central"
}

# Virtual Network
aks_vnet_name          = "vnet-sr-uat-001"
aks_vnet_address_space = ["172.40.1.0/26"]

# Subnets
vm_subnet_name           = "snet-vm-qatar-001"
vm_subnet_address_prefix = ["172.40.1.48/28"]

pe_subnet_name           = "snet-pe-qatar-001"
pe_subnet_address_prefix = ["172.40.1.32/28"]

# Virtual Machine
vm_names                     = ["vm-name-1", "vm-name-2", "vm-name-3"]
vm_count                     = 3
vm_size                      = "Standard_D4s_v3"  #old value Standard_DS1_v2
vm_public_ip                 = false
admin_username               = "azadmin"
# admin_password is not set here so that it is provided at runtime.
zones                        = 3
vm_os_disk_image             = {
  publisher = "MicrosoftWindowsServer"
  offer     = "WindowsServer"
  sku       = "2022-datacenter-azure-edition"
  version   = "latest"
}
domain_name_label            = "windowsnpcvmtrial"
vm_os_disk_storage_account_type = "StandardSSD_LRS"
default_node_pool_availability_zones = ["1", "2", "3"]

# Key Vault
key_vault_name = "kv-sr-uat-01"
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
acr_name                   = "crsruat01"
acr_admin_enabled          = false
acr_sku                    = "Premium"
acr_georeplication_locations = []
zone_redundancy_enabled      = true
# Databricks Workspace
workspace_name                              = "dbw-sr-uat-01"
databricks_vnet_resource_group_name           = "rg-sr-uat-001"
databricks_private_subnet_name                = "snet-dbw-uat-qatar-001"
databricks_public_subnet_name                 = "snet-dbw-uat-qatar-002"
public_subnet_address_prefixes                = ["172.40.1.16/28"]
private_subnet_address_prefixes               = ["172.40.1.0/28"]
databricks_security_group_prefix              = "nsg-databricks"
managed_resource_group_name                   = "rg-sr-uat-managed-dbw"
sku_dbw                                       = "premium"

# Datalake Storage
datalake_storage_account_name   = "dlssruat01"
datalake_account_tier             = "Standard"
datalake_account_replication_type = "ZRS"
datalake_account_kind             = "StorageV2"
datalake_is_hns_enabled           = true
datalake_filesystem_name          = "dlsfssruat"
datalake_filesystem_properties    = {
  hello = "aGVsbG8="
}
datalake_storage_account_pe = "dls-sr-uat-01" 
acr_name_pe                   = "cr-sr-uat-01"
soft_delete_retention_days        = 7
enable_versioning                 = true
enable_change_feed                = true
#########################################
# Ubuntu Virtual Machine (New Variables)
#########################################
ubuntu_vm_name = "ubuntu-sr-uat"
ubuntu_vm_count = 1
ubuntu_vm_size  = "Standard_D4s_v3"
ubuntu_vm_public_ip = false
ubuntu_admin_username = "ubuntuadmin"
# ubuntu_admin_password is not set here so that it is provided at runtime.
# Optionally, you can override the default OS image by providing a different map here.
# ubuntu_vm_os_disk_image = {
#   publisher = "Canonical"
#   offer     = "UbuntuServer"
#   sku       = "20.04-LTS"
#   version   = "latest"
# }
ubuntu_domain_name_label = "ubuntunpcvmtrial"
ubuntu_vm_os_disk_storage_account_type = "StandardSSD_LRS"
