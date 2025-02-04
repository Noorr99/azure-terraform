# Resource Group & Location
resource_group_name = "rg-nih-dev-001"
location            = "qatarcentral"
tags = {
  createdWith = "Terraform"
  Environment = "dev"
  Workload    = "nih"
  Region      = "Qatar Central"
}

# Virtual Network
aks_vnet_name          = "vnet-dev-qatar-001"
aks_vnet_address_space = ["192.168.71.128/26"]

# Shared Subnet (for SQL, Key Vault, Data Lake)
shared_subnet_name           = "snet-nih-pe-qatar-001"
shared_subnet_address_prefix = ["192.168.71.128/28"]

# AKS Subnet
aks_subnet_name           = "snet-nih-aks-qatar-001"
aks_subnet_address_prefix = ["192.168.71.160/27"]

# Key Vault
key_vault_name = "kv-nih-dev-001"
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

# Data Lake Storage
datalake_storage_account_name   = "dlsnihdev01"
datalake_account_tier             = "Standard"
datalake_account_replication_type = "LRS"
datalake_account_kind             = "StorageV2"
datalake_is_hns_enabled           = true

# SQL Database
sql_server_name     = "sql-server-nih-dev"
sql_admin_username  = "sqladmin"
# sql_admin_password must be provided at runtime.
sql_database_name   = "sql-db-dev"
sql_database_dtu    = "100"
sql_database_tier   = "Standard"
sql_database_size_gb = 250
long_term_retention_backup = 0
geo_backup_enabled  = false
storage_account_type = "Local"
sku_name            = "P1"
zone_redundant      = false

# Data Factory
data_factory_name        = "adf-nih-dev"
public_network_enabled   = false
data_factory_identity_type = "SystemAssigned"

# Route Table (for AKS subnet)
route_table_name = "rt-aks"
route_name       = "default-route-0-0-0-0"
firewall_private_ip = "192.168.71.129" // old value = "192.168.64.70"

# Private DNS Zone for AKS Control Plane
aks_private_dns_zone_name = "privatelink.qatarcentral.azmk8s.io"

# AKS Cluster
aks_cluster_name        = "aks-nih-dev-001"
kubernetes_version      = "1.30.7"
sku_tier                = "Free"
automatic_channel_upgrade = "stable"
default_node_pool_name  = "system"
default_node_pool_vm_size = "Standard_D4ds_v4"
default_node_pool_node_labels = {}
default_node_pool_enable_auto_scaling    = false
default_node_pool_enable_host_encryption = false
default_node_pool_enable_node_public_ip  = false
default_node_pool_max_pods               = 50
default_node_pool_node_count             = 3
default_node_pool_os_disk_type           = "Managed"

network_plugin         = "kubenet"
outbound_type          = "loadBalancer" // old value: "userDefinedRouting"
network_service_cidr   = "10.1.0.0/24"
network_dns_service_ip = "10.1.0.10"
role_based_access_control_enabled = true
azure_rbac_enabled                = true
admin_group_object_ids            = []
admin_username                    = "azadmin"
# ssh_public_key must be provided at runtime.

keda_enabled                     = true
vertical_pod_autoscaler_enabled  = true
workload_identity_enabled        = true
oidc_issuer_enabled              = true
open_service_mesh_enabled        = true
image_cleaner_enabled            = true
azure_policy_enabled             = true
http_application_routing_enabled = false

# (Optional) Log Analytics Workspace
log_analytics_workspace_id = null
