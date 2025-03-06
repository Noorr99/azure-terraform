# Resource Group & Location
resource_group_name = "rg-compliance-prod-001"
location            = "qatarcentral"
tags = {
  createdWith = "Terraform"
  Environment = "prod"
  Workload    = "DTM"
  Region      = "Qatar Central"
}

# Virtual Network
dtm_vnet_name          = "vnet-dtm-prod"
dtm_vnet_address_space = ["172.40.0.128/26"]

# Subnets
vm_subnet_name           = "snet-dtm-prod-fe"
vm_subnet_address_prefix = ["172.40.0.128/28"]

pe_subnet_name           = "snet-dtm-prod-pe"
pe_subnet_address_prefix = ["172.40.0.160/28"]

data_subnet_name           = "snet-dtm-prod-data"
data_subnet_address_prefix = ["172.40.0.144/28"]

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
    "vm0" = "vm-dtm-prod-fe-01"   # was "sr-shir-01", shortened
}
*/
vm_name = "vm-dtm-prod-01"
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
sql_server_name     = "dtm-prod-db-01"
sql_admin_username  = "sqladmin"
# sql_admin_password must be provided at runtime.
sql_database_name   = "sql-db-prod"
sql_database_dtu    = "500"
sql_database_tier   = "Premium"
sql_database_size_gb = 250
long_term_retention_backup = 7
geo_backup_enabled  = false
storage_account_type = "Zone"
sku_name            = "P4"
zone_redundant      = false

# Cognitive Service configuration for Azure AI Language (using TextAnalytics)
cognitive_service_name                    = "lang-prod-dtm-001"   // Updated name to indicate TextAnalytics
cognitive_service_kind                    = "TextAnalytics"       // Allowed value for Language capabilities
cognitive_service_sku                     = "S"
cognitive_public_network_access_enabled   = false
cognitive_custom_subdomain_name           = "langcustomsubdomainprod"   // Must be unique in your region
cognitive_service_identity_type         = "SystemAssigned"


# Load Balancer Variables
# Load Balancer Settings
lb_name               = "lb-prod-dtm-01"
lb_sku                = "Standard"
lb_frontend_name      = "lb-frontend"
lb_private_ip_allocation = "Dynamic"
lb_backend_pool_name  = "lb-backend-pool"
lb_probe_name         = "lb-probe"
lb_probe_protocol     = "Tcp"
lb_probe_port         = 80
lb_probe_interval     = 5
lb_probe_count        = 2
lb_rule_count         = 5
lb_rule_name_prefix   = "lb-rule"
lb_rule_protocol      = "Tcp"
lb_rule_start_port    = 80
lb_ip_configuration_name = "ipconfig1"

# Virtual Machines Count
vm_count = 2