////////////////////////////////////////////////////////////////////////
// Existing Variables (Resource Group, Location, Tags)
////////////////////////////////////////////////////////////////////////
variable "resource_group_name" {
  description = "Specifies the name of the resource group."
  type        = string
}

variable "location" {
  description = "Specifies the Azure region where resources will be created."
  type        = string
}

variable "tags" {
  description = "Specifies tags to apply to all resources."
  type        = map(string)
}

////////////////////////////////////////////////////////////////////////
// Virtual Network (VNet) Variables
////////////////////////////////////////////////////////////////////////
variable "aks_vnet_name" {
  description = "Specifies the name of the Azure virtual network."
  type        = string
}

variable "aks_vnet_address_space" {
  description = "Specifies the address space for the Azure virtual network."
  type        = list(string)
}

variable "shared_subnet_name" {
  description = "The name of the shared subnet for SQL Database, Key Vault, and Data Lake."
  type        = string
}

variable "shared_subnet_address_prefix" {
  description = "The address prefix for the shared subnet."
  type        = list(string)
}

////////////////////////////////////////////////////////////////////////
// AKS Subnet Variables
////////////////////////////////////////////////////////////////////////
variable "aks_subnet_name" {
  description = "The name of the subnet for AKS node pool(s)."
  type        = string
}

variable "aks_subnet_address_prefix" {
  description = "The address prefix for the AKS subnet."
  type        = list(string)
}

////////////////////////////////////////////////////////////////////////
// Key Vault Variables
////////////////////////////////////////////////////////////////////////
variable "key_vault_name" {
  description = "Specifies the name of the Key Vault."
  type        = string
}

variable "tenant_id" {
  description = "Specifies the tenant ID for the Key Vault and AKS."
  type        = string
  sensitive   = true
}

variable "key_vault_sku" {
  description = "Specifies the SKU of the Key Vault. Possible values are 'standard' or 'premium'."
  type        = string
}

variable "key_vault_enabled_for_deployment" {
  description = "Allows Azure VMs to retrieve certificates stored as secrets."
  type        = bool
}

variable "key_vault_enabled_for_disk_encryption" {
  description = "Allows Azure Disk Encryption to retrieve secrets and unwrap keys."
  type        = bool
}

variable "key_vault_enabled_for_template_deployment" {
  description = "Allows Azure Resource Manager to retrieve secrets from the key vault."
  type        = bool
}

variable "key_vault_enable_rbac_authorization" {
  description = "Specifies whether Key Vault uses RBAC for authorization."
  type        = bool
}

variable "key_vault_purge_protection_enabled" {
  description = "Specifies if purge protection is enabled on the Key Vault."
  type        = bool
}

variable "key_vault_soft_delete_retention_days" {
  description = "Specifies the soft-delete retention days for the Key Vault."
  type        = number
}

variable "key_vault_bypass" {
  description = "Specifies which traffic can bypass network rules for Key Vault. Options: 'AzureServices' or 'None'."
  type        = string
}

variable "key_vault_default_action" {
  description = "Specifies the default action for network rules on Key Vault. Options: 'Allow' or 'Deny'."
  type        = string
}

variable "key_vault_ip_rules" {
  description = "List of IP addresses/CIDR blocks allowed to access the Key Vault."
  type        = list(string)
}

////////////////////////////////////////////////////////////////////////
// Data Lake Storage Variables
////////////////////////////////////////////////////////////////////////

variable "datalake_storage_account_name" {
  description = "The name of the Data Lake Storage account."
  type        = string
}

variable "datalake_storage_account_pe" {
  description = "The name of the Data Lake Storage account private endpoint."
  type        = string
}

variable "datalake_account_tier" {
  description = "The tier of the Data Lake Storage account."
  type        = string
}

variable "datalake_account_replication_type" {
  description = "The replication type of the Data Lake Storage account."
  type        = string
}

variable "datalake_account_kind" {
  description = "The kind of the Data Lake Storage account."
  type        = string
}

variable "datalake_is_hns_enabled" {
  description = "Whether the hierarchical namespace is enabled."
  type        = bool
}

variable "datalake_filesystem_name" {
  description = "The name of the Data Lake Storage Gen2 filesystem."
  type        = string
}

variable "datalake_filesystem_properties" {
  description = "The properties of the Data Lake Storage Gen2 filesystem."
  type        = map(string)
}

////////////////////////////////////////////////////////////////////////
// SQL Database Variables
////////////////////////////////////////////////////////////////////////
variable "sql_server_name" {
  description = "Specifies the name of the SQL Server."
  type        = string
}

variable "sql_admin_username" {
  description = "Specifies the admin username for the SQL Server."
  type        = string
}

variable "sql_admin_password" {
  description = "Specifies the admin password for the SQL Server."
  type        = string
  sensitive   = true
}

variable "sql_database_name" {
  description = "Specifies the name of the SQL Database."
  type        = string
}

variable "sql_database_dtu" {
  description = "Specifies the DTU allocation for the SQL Database."
  type        = string
}

variable "sql_database_tier" {
  description = "Specifies the pricing tier for the SQL Database."
  type        = string
}

variable "sql_database_size_gb" {
  description = "Specifies the maximum storage size for the SQL Database in GB."
  type        = number
}

variable "long_term_retention_backup" {
  description = "Specifies the size of the long-term retention backup in GB."
  type        = number
}

variable "geo_backup_enabled" {
  description = "Specifies whether geo-backup is enabled."
  type        = bool
}

variable "storage_account_type" {
  description = "Specifies the type of storage account used."
  type        = string
}

variable "sku_name" {
  description = "Specifies the sku name."
  type        = string
}

variable "zone_redundant" {
  description = "Specifies whether zone redundancy is enabled."
  type        = bool
}

////////////////////////////////////////////////////////////////////////
// Data Factory Variables
////////////////////////////////////////////////////////////////////////
variable "data_factory_name" {
  description = "Specifies the name of the Azure Data Factory."
  type        = string
}

variable "public_network_enabled" {
  description = "Specifies whether the Data Factory is visible to the public network."
  type        = bool
}

variable "data_factory_identity_type" {
  description = "Specifies the identity type for the Data Factory. Valid values include 'SystemAssigned', 'UserAssigned' or 'SystemAssigned, UserAssigned'."
  type        = string
}

////////////////////////////////////////////////////////////////////////
// Route Table Variables (for AKS Subnet)
////////////////////////////////////////////////////////////////////////
variable "route_table_name" {
  description = "The name of the route table for the AKS subnet."
  type        = string
}

variable "route_name" {
  description = "The name of the default UDR route."
  type        = string
}

variable "firewall_private_ip" {
  description = "Private IP of your firewall/NVA for egress. If no firewall, adjust accordingly."
  type        = string
}

////////////////////////////////////////////////////////////////////////
// Private DNS Zone for AKS
////////////////////////////////////////////////////////////////////////
variable "aks_private_dns_zone_name" {
  description = "Private DNS zone for the private AKS control plane. Adjust region if needed."
  type        = string
}

////////////////////////////////////////////////////////////////////////
// AKS Cluster Variables
////////////////////////////////////////////////////////////////////////
variable "aks_cluster_name" {
  description = "Specifies the name of the AKS cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "AKS Kubernetes version."
  type        = string
}

variable "sku_tier" {
  description = "(Optional) The SKU Tier for this Kubernetes Cluster: 'Free' or 'Paid'."
  type        = string
}

variable "automatic_channel_upgrade" {
  description = "The upgrade channel for this Kubernetes Cluster: 'patch', 'rapid', or 'stable'."
  type        = string
}

variable "default_node_pool_name" {
  description = "Name of the default AKS node pool."
  type        = string
}

variable "default_node_pool_vm_size" {
  description = "Specifies the VM size for the default node pool."
  type        = string
}

variable "default_node_pool_node_labels" {
  description = "A map of Kubernetes labels for nodes in this pool."
  type        = map(string)
}

variable "default_node_pool_enable_auto_scaling" {
  description = "Enable autoscaling for the default node pool."
  type        = bool
}

variable "default_node_pool_enable_host_encryption" {
  description = "Enable host encryption on node pool VMs."
  type        = bool
}

variable "default_node_pool_enable_node_public_ip" {
  description = "Enable public IP for each node in this pool."
  type        = bool
}

variable "default_node_pool_max_pods" {
  description = "Max pods per node in the default node pool."
  type        = number
}

variable "default_node_pool_node_count" {
  description = "Initial node count in the default node pool."
  type        = number
}

variable "default_node_pool_os_disk_type" {
  description = "OS disk type: 'Managed' or 'Ephemeral'."
  type        = string
}

variable "network_plugin" {
  description = "AKS network plugin: 'azure' or 'kubenet'."
  type        = string
}

variable "network_plugin_mode" {
  description = "AKS network plugin mode"
  type        = string
}

variable "outbound_type" {
  description = "Outbound (egress) type: 'loadBalancer' or 'userDefinedRouting'."
  type        = string
}

variable "network_service_cidr" {
  description = "Service CIDR for AKS."
  type        = string
}

variable "network_dns_service_ip" {
  description = "DNS service IP for AKS."
  type        = string
}

variable "role_based_access_control_enabled" {
  description = "Enable Kubernetes RBAC."
  type        = bool
}

variable "azure_rbac_enabled" {
  description = "Enable Azure RBAC on AKS."
  type        = bool
}

variable "admin_group_object_ids" {
  description = "List of Azure AD group object IDs with admin role on the cluster."
  type        = list(string)
}

variable "admin_username" {
  description = "Admin username for the AKS nodes."
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key used to access the AKS nodes."
  type        = string
}

variable "keda_enabled" {
  description = "Enable KEDA autoscaler."
  type        = bool
}

variable "vertical_pod_autoscaler_enabled" {
  description = "Enable vertical pod autoscaler."
  type        = bool
}

variable "workload_identity_enabled" {
  description = "Enable Microsoft Entra Workload Identity on the cluster."
  type        = bool
}

variable "oidc_issuer_enabled" {
  description = "Enable or disable the OIDC issuer URL."
  type        = bool
}

variable "open_service_mesh_enabled" {
  description = "Enable Open Service Mesh add-on."
  type        = bool
}

variable "image_cleaner_enabled" {
  description = "Enable Image Cleaner add-on."
  type        = bool
}

variable "azure_policy_enabled" {
  description = "Enable Azure Policy add-on."
  type        = bool
}

variable "http_application_routing_enabled" {
  description = "Enable HTTP Application Routing add-on."
  type        = bool
}

variable "default_node_pool_availability_zones" {
  description = "Specifies the availability zones of the default node pool"
  default     = ["1", "2", "3"]
  type        = list(string)
}

// User Node Vars

variable "user_node_pool_name" {
  description = "Name of the user node pool"
  type        = string
  default     = "user"
}

variable "user_node_pool_vm_size" {
  description = "VM size for the user node pool"
  type        = string
  default     = "Standard_D4ds_v4"
}

variable "user_node_pool_node_count" {
  description = "Initial node count for the user node pool"
  type        = number
  default     = 5
}

variable "user_node_pool_os_disk_type" {
  description = "OS disk type for the user node pool"
  type        = string
  default     = "Managed"
}

variable "user_node_pool_node_labels" {
  description = "Labels for the user node pool nodes"
  type        = map(string)
  default     = {}
}

variable "user_node_pool_enable_auto_scaling" {
  description = "Whether auto-scaling is enabled for the user node pool"
  type        = bool
  default     = false
}

variable "user_node_pool_max_pods" {
  description = "Maximum number of pods per node for the user node pool"
  type        = number
  default     = 50
}

variable "user_node_pool_availability_zones" {
  description = "Availability zones for the user node pool"
  type        = list(string)
  default     = ["2", "3"]
}


////////////////////////////////////////////////////////////////////////
// Log Analytics Workspace (Optional)
////////////////////////////////////////////////////////////////////////
variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace (if any)."
  type        = string
}
