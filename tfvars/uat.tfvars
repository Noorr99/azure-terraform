# Resource Group & Location
resource_group_name = "rg-compliance-uat-001"
location            = "qatarcentral"
tags = {
  createdWith = "Terraform"
  Environment = "uat"
  Workload    = "DTM"
  Region      = "Qatar Central"
}

# Virtual Network
dtm_vnet_name          = "vnet-dtm-uat"
dtm_vnet_address_space = ["172.40.0.64/26"]

# Subnets
vm_subnet_name           = "snet-dtm-uat-fe"
vm_subnet_address_prefix = ["172.40.0.64/28"]

pe_subnet_name           = "snet-dtm-uat-pe"
pe_subnet_address_prefix = ["172.40.0.96/28"]

data_subnet_name           = "snet-dtm-uat-data"
data_subnet_address_prefix = ["172.40.0.80/28"]

# Virtual Machine
//availability_set_name = "sr-prod-qat-as-01"
/*
vm_names = {
  "vm0" = "sr-prod-shir-01"
  "vm1" = "sr-prod-jb-informatica-01"
  "vm3" = "sr-prod-pbi-gw-01"
}
*/


/*
vm_names = {
    "vm0" = "vm-dtm-uat-fe-01"   # was "sr-shir-01", shortened
}
*/
vm_name = "vm-dtm-uat-01"
//vm_count                     = 3
vm_size                      = "Standard_D4s_v5"  #old value Standard_DS1_v2 D8s v3
vm_public_ip                 = false
admin_username               = "azadmin"
# admin_password is not set here so that it is provided at runtime.
//zone                         = ["2", "3"]
vm_os_disk_image             = {
  publisher = "MicrosoftWindowsServer"
  offer     = "WindowsServer"
  sku       = "2022-datacenter-azure-edition"
  version   = "latest"
}
domain_name_label            = "windowsnpcvmtrial"
vm_os_disk_storage_account_type = "StandardSSD_LRS"
os_disk_size_gb = 128

# New Data Disk Variables
data_disk_name                      = "additional-datadisk-01"
data_disk_caching                   = "None"
data_disk_create_option             = "Empty"
data_disk_size_gb                   = 512
data_disk_lun                       = 0
data_disk_write_accelerator_enabled = false
data_disk_managed_disk_type         = "StandardSSD_LRS"

# SQL Database
sql_server_name     = "dtm-uat-db-01"
sql_admin_username  = "sqladmin"
# sql_admin_password must be provided at runtime.
sql_database_name   = "sql-db-uat"
sql_database_dtu    = "200"
sql_database_tier   = "Standard"
sql_database_size_gb = 250
long_term_retention_backup = 0
geo_backup_enabled  = false
storage_account_type = "Local"
sku_name            = "S4"
zone_redundant      = false

# Cognitive Service configuration for Azure AI Language (using TextAnalytics)
cognitive_service_name                    = "lang-uat-dtm-001"   // Updated name to indicate TextAnalytics
cognitive_service_kind                    = "TextAnalytics"       // Allowed value for Language capabilities
cognitive_service_sku                     = "S"
cognitive_public_network_access_enabled   = false
cognitive_custom_subdomain_name           = "langcustomsubdomainuat"   // Must be unique in your region
cognitive_service_identity_type         = "SystemAssigned"
