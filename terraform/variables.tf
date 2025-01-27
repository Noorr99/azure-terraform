////////////////////////////////////////////////////////////////////////
// Existing Variables (Resource Group, Location, Tags)
////////////////////////////////////////////////////////////////////////
variable "resource_group_name" {
  description = "Specifies the name of the resource group."
  type        = string
  default     = "rg-nih-dev-002"
}

variable "location" {
  description = "Specifies the Azure region where resources will be created."
  type        = string
  default     = "qatarcentral"
}

variable "tags" {
  description = "Specifies tags to apply to all resources."
  type        = map(string)
  default = {
    createdWith = "Terraform"
  }
}

////////////////////////////////////////////////////////////////////////
// Virtual Network (VNet) Variables
////////////////////////////////////////////////////////////////////////
variable "aks_vnet_name" {
  description = "Specifies the name of the Azure virtual network."
  type        = string
  default     = "vnet-dev-qatar-002"
}

variable "aks_vnet_address_space" {
  description = "Specifies the address space for the Azure virtual network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "shared_subnet_name" {
  description = "The name of the shared subnet for SQL Database, Key Vault, and Data Lake."
  type        = string
  default     = "snet-shared-qatar-002"
}

variable "shared_subnet_address_prefix" {
  description = "The address prefix for the shared subnet."
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

////////////////////////////////////////////////////////////////////////
// AKS Subnet Variables
////////////////////////////////////////////////////////////////////////
variable "aks_subnet_name" {
  description = "The name of the subnet for AKS node pool(s)."
  type        = string
  default     = "snet-aks-qatar-002"
}

variable "aks_subnet_address_prefix" {
  description = "The address prefix for the AKS subnet."
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

////////////////////////////////////////////////////////////////////////
// Key Vault Variables
////////////////////////////////////////////////////////////////////////
variable "key_vault_name" {
  description = "Specifies the name of the Key Vault."
  type        = string
  default     = "kv-nih-shared-dev-02"
}

variable "tenant_id" {
  description = "Specifies the tenant ID for the Key Vault and AKS."
  type        = string
}

variable "key_vault_sku" {
  description = "Specifies the SKU of the Key Vault. Possible values are 'standard' or 'premium'."
  type        = string
  default     = "standard"
}

variable "key_vault_enabled_for_deployment" {
  description = "Allows Azure VMs to retrieve certificates stored as secrets."
  type        = bool
  default     = false
}

variable "key_vault_enabled_for_disk_encryption" {
  description = "Allows Azure Disk Encryption to retrieve secrets and unwrap keys."
  type        = bool
  default     = false
}

variable "key_vault_enabled_for_template_deployment" {
  description = "Allows Azure Resource Manager to retrieve secrets from the key vault."
  type        = bool
  default     = false
}

variable "key_vault_enable_rbac_authorization" {
  description = "Specifies whether Key Vault uses RBAC for authorization."
  type        = bool
  default     = false
}

variable "key_vault_purge_protection_enabled" {
  description = "Specifies if purge protection is enabled on the Key Vault."
  type        = bool
  default     = false
}

variable "key_vault_soft_delete_retention_days" {
  description = "Specifies the soft-delete retention days for the Key Vault."
  type        = number
  default     = 30
}

variable "key_vault_bypass" {
  description = "Specifies which traffic can bypass network rules for Key Vault. Options: 'AzureServices' or 'None'."
  type        = string
  default     = "AzureServices"
}

variable "key_vault_default_action" {
  description = "Specifies the default action for network rules on Key Vault. Options: 'Allow' or 'Deny'."
  type        = string
  default     = "Allow"
}

variable "key_vault_ip_rules" {
  description = "List of IP addresses/CIDR blocks allowed to access the Key Vault."
  type        = list(string)
  default     = []
}

////////////////////////////////////////////////////////////////////////
// Data Lake Storage Variables
////////////////////////////////////////////////////////////////////////
variable "datalake_storage_account_name" {
  description = "The name of the Data Lake Storage account."
  type        = string
  default     = "dlsnihdev02"
}

variable "datalake_account_tier" {
  description = "The tier of the Data Lake Storage account."
  type        = string
  default     = "Standard"
}

variable "datalake_account_replication_type" {
  description = "The replication type of the Data Lake Storage account."
  type        = string
  default     = "LRS"
}

variable "datalake_account_kind" {
  description = "The kind of the Data Lake Storage account."
  type        = string
  default     = "StorageV2"
}

variable "datalake_is_hns_enabled" {
  description = "Specifies whether hierarchical namespace is enabled for the Data Lake."
  type        = bool
  default     = true
}

////////////////////////////////////////////////////////////////////////
// SQL Database Variables
////////////////////////////////////////////////////////////////////////
variable "sql_server_name" {
  description = "Specifies the name of the SQL Server."
  type        = string
  default     = "sql-server-dev-nih"
}

variable "sql_admin_username" {
  description = "Specifies the admin username for the SQL Server."
  type        = string
  default     = "sqladmin"
}

variable "sql_admin_password" {
  description = "Specifies the admin password for the SQL Server."
  type        = string
  sensitive   = true
}

variable "sql_database_name" {
  description = "Specifies the name of the SQL Database."
  type        = string
  default     = "sql-db-dev"
}

variable "sql_database_dtu" {
  description = "Specifies the DTU allocation for the SQL Database."
  type        = string
  default     = "125"
}

variable "sql_database_tier" {
  description = "Specifies the pricing tier for the SQL Database."
  type        = string
  default     = "Premium"
}

variable "sql_database_size_gb" {
  description = "Specifies the maximum storage size for the SQL Database in GB."
  type        = number
  default     = 500
}

variable "long_term_retention_backup" {
  description = "Specifies the size of the long-term retention backup in GB."
  type        = number
  default     = 100
}

variable "public_network_access_enabled" { 
  description = "(Optional) Whether public network access is allowed for this Key Vault."
  type        = bool
  default     = false
}

variable "data_factory_name" {
  description = "Specifies the name of the Azure Data Factory."
  type        = string
  default     = "adf-nih-dev-test"
}

////////////////////////////////////////////////////////////////////////
// Route Table Variables (for AKS Subnet)
////////////////////////////////////////////////////////////////////////
variable "route_table_name" {
  description = "The name of the route table for the AKS subnet."
  type        = string
  default     = "rt-aks"
}

variable "route_name" {
  description = "The name of the default UDR route."
  type        = string
  default     = "default-route-0-0-0-0"
}

variable "firewall_private_ip" {
  description = "Private IP of your firewall/NVA for egress. If no firewall, adjust accordingly."
  type        = string
  default     = "10.0.0.4"
}

////////////////////////////////////////////////////////////////////////
// Private DNS Zone for AKS
////////////////////////////////////////////////////////////////////////
variable "aks_private_dns_zone_name" {
  description = "Private DNS zone for the private AKS control plane. Adjust region if needed."
  type        = string
  default     = "privatelink.northeurope.azmk8s.io"
}

////////////////////////////////////////////////////////////////////////
// AKS Cluster Variables
////////////////////////////////////////////////////////////////////////
variable "aks_cluster_name" {
  description = "Specifies the name of the AKS cluster."
  type        = string
  default     = "aks-nih-dev-002"
}

variable "kubernetes_version" {
  description = "AKS Kubernetes version."
  type        = string
  default     = "1.30.7"
}

variable "sku_tier" {
  description = "(Optional) The SKU Tier for this Kubernetes Cluster: 'Free' or 'Paid'."
  type        = string
  default     = "Free"
}

variable "automatic_channel_upgrade" {
  description = "The upgrade channel for this Kubernetes Cluster: 'patch', 'rapid', or 'stable'."
  type        = string
  default     = "stable"
}

variable "default_node_pool_name" {
  description = "Name of the default AKS node pool."
  type        = string
  default     = "system"
}

variable "default_node_pool_vm_size" {
  description = "Specifies the VM size for the default node pool."
  type        = string
  default     = "Standard_F8s_v2"
}

variable "default_node_pool_availability_zones" {
  description = "Availability zones for the default node pool."
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "default_node_pool_node_labels" {
  description = "A map of Kubernetes labels for nodes in this pool."
  type        = map(string)
  default     = {}
}

variable "default_node_pool_node_taints" {
  description = "A list of Kubernetes taints for nodes in this pool."
  type        = list(string)
  default     = []
}

variable "default_node_pool_enable_auto_scaling" {
  description = "Enable autoscaling for the default node pool."
  type        = bool
  default     = true
}

variable "default_node_pool_enable_host_encryption" {
  description = "Enable host encryption on node pool VMs."
  type        = bool
  default     = false
}

variable "default_node_pool_enable_node_public_ip" {
  description = "Enable public IP for each node in this pool."
  type        = bool
  default     = false
}

variable "default_node_pool_max_pods" {
  description = "Max pods per node in the default node pool."
  type        = number
  default     = 50
}

variable "default_node_pool_max_count" {
  description = "Max number of nodes in the default node pool."
  type        = number
  default     = 10
}

variable "default_node_pool_min_count" {
  description = "Min number of nodes in the default node pool."
  type        = number
  default     = 3
}

variable "default_node_pool_node_count" {
  description = "Initial node count in the default node pool."
  type        = number
  default     = 3
}

variable "default_node_pool_os_disk_type" {
  description = "OS disk type: 'Managed' or 'Ephemeral'."
  type        = string
  default     = "Managed"
}

variable "network_plugin" {
  description = "AKS network plugin: 'azure' or 'kubenet'."
  type        = string
  default     = "azure"
}

variable "outbound_type" {
  description = "Outbound (egress) type: 'loadBalancer' or 'userDefinedRouting'."
  type        = string
  default     = "userDefinedRouting"
}

variable "network_service_cidr" {
  description = "Service CIDR for AKS."
  type        = string
  default     = "10.2.0.0/24"
}

variable "network_dns_service_ip" {
  description = "DNS service IP for AKS."
  type        = string
  default     = "10.2.0.10"
}

variable "role_based_access_control_enabled" {
  description = "Enable Kubernetes RBAC."
  type        = bool
  default     = true
}

variable "azure_rbac_enabled" {
  description = "Enable Azure RBAC on AKS."
  type        = bool
  default     = true
}

variable "admin_group_object_ids" {
  description = "List of Azure AD group object IDs with admin role on the cluster."
  type        = list(string)
  default     = []
}

variable "admin_username" {
  description = "Admin username for the AKS nodes."
  type        = string
  default     = "azadmin"
}

variable "ssh_public_key" {
  description = "SSH public key used to access the AKS nodes."
  type        = string
}

variable "keda_enabled" {
  description = "Enable KEDA autoscaler."
  type        = bool
  default     = true
}

variable "vertical_pod_autoscaler_enabled" {
  description = "Enable vertical pod autoscaler."
  type        = bool
  default     = true
}

variable "workload_identity_enabled" {
  description = "Enable Microsoft Entra Workload Identity on the cluster."
  type        = bool
  default     = true
}

variable "oidc_issuer_enabled" {
  description = "Enable or disable the OIDC issuer URL."
  type        = bool
  default     = true
}

variable "open_service_mesh_enabled" {
  description = "Enable Open Service Mesh add-on."
  type        = bool
  default     = true
}

variable "image_cleaner_enabled" {
  description = "Enable Image Cleaner add-on."
  type        = bool
  default     = true
}

variable "azure_policy_enabled" {
  description = "Enable Azure Policy add-on."
  type        = bool
  default     = true
}

variable "http_application_routing_enabled" {
  description = "Enable HTTP Application Routing add-on."
  type        = bool
  default     = false
}

////////////////////////////////////////////////////////////////////////
// Log Analytics Workspace (Optional)
////////////////////////////////////////////////////////////////////////
variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace (if any)."
  type        = string
  default     = null
}
