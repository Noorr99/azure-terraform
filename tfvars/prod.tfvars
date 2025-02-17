# Resource Group & Location
resource_group_name = "rg-sr-prod"
location            = "qatarcentral"
tags = {
  createdWith = "Terraform"
  Environment = "prod"
  Workload    = "Shared Resources"
  Region      = "Qatar Central"
}

# Virtual Network
aks_vnet_name          = "vnet-sr-prod-001"
aks_vnet_address_space = ["172.40.2.0/25"]

# Subnets
vm_subnet_name           = "snet-vm-qatar-001"
vm_subnet_address_prefix = ["172.40.2.96/27"]

pe_subnet_name           = "snet-pe-qatar-001"
pe_subnet_address_prefix = ["172.40.2.64/27"]

# Virtual Machine
availability_set_name = "sr-prod-qat-as-01"
vm_names = {
  "vm0" = "sr-prod-shir-01"
  "vm1" = "sr-prod-jb-informatica-01"
  "vm3" = "sr-prod-pbi-gw-01"
}
//vm_count                     = 3
vm_size                      = "Standard_D8s_v3"  #old value Standard_DS1_v2 D8s v3
vm_public_ip                 = false
admin_username               = "azadmin"
# admin_password is not set here so that it is provided at runtime.
zones                        = ["2", "3"]
vm_os_disk_image             = {
  publisher = "MicrosoftWindowsServer"
  offer     = "WindowsServer"
  sku       = "2022-datacenter-azure-edition"
  version   = "latest"
}
domain_name_label            = "windowsnpcvmtrial"
vm_os_disk_storage_account_type = "StandardSSD_LRS"

# Key Vault
key_vault_name = "kv-sr-prod-01"
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
acr_name                   = "crsrprod01"
acr_admin_enabled          = false
acr_sku                    = "Premium"
acr_georeplication_locations = []
zone_redundancy_enabled      = true
# Databricks Workspace
workspace_name                              = "dbw-sr-prod-01"
databricks_vnet_resource_group_name           = "rg-sr-prod-001"
databricks_private_subnet_name                = "snet-dbw-prod-qatar-001"
databricks_public_subnet_name                 = "snet-dbw-prod-qatar-002"
public_subnet_address_prefixes                = ["172.40.2.32/27"]
private_subnet_address_prefixes               = ["172.40.2.0/27"]
databricks_security_group_prefix              = "nsg-databricks"
managed_resource_group_name                   = "rg-sr-prod-managed-dbw"
sku_dbw                                       = "premium"

# Datalake Storage
datalake_storage_account_name   = "dlssrprod01"
datalake_account_tier             = "Premium"
datalake_account_replication_type = "ZRS"
datalake_account_kind             = "StorageV2"
datalake_is_hns_enabled           = true
datalake_filesystem_name          = "dlsfssrprod"
datalake_filesystem_properties    = {
  hello = "aGVsbG8="
}
datalake_storage_account_pe = "dls-sr-prod-01" 
acr_name_pe                   = "cr-sr-prod-01"
soft_delete_retention_days        = 7
enable_versioning                 = true
enable_change_feed                = true
#########################################
# Ubuntu Virtual Machine (New Variables)
#########################################
ubuntu_vm_name = "sr-prod-devops-01"
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
