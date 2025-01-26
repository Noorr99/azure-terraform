///////////////////////////////////////////////////////////
// Resource Group & Location
///////////////////////////////////////////////////////////
variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
  default     = "rg-nih-dev-002"
}

variable "location" {
  type        = string
  description = "Azure region for resources."
  default     = "northeurope"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources."
  default = {
    createdWith = "Terraform"
  }
}

///////////////////////////////////////////////////////////
// Shared Subnet (existing usage for SQL, KV, etc.)
///////////////////////////////////////////////////////////
variable "shared_subnet_name" {
  type        = string
  description = "Name of the shared subnet."
  default     = "snet-shared-qatar-002"
}

variable "shared_subnet_address_prefix" {
  type        = list(string)
  description = "CIDR for the shared subnet."
  default     = ["10.0.1.0/24"]
}

///////////////////////////////////////////////////////////
// New Subnet for AKS
///////////////////////////////////////////////////////////
variable "aks_subnet_name" {
  type        = string
  description = "Name of the subnet for AKS node pool(s)."
  default     = "snet-aks-qatar-002"
}

variable "aks_subnet_address_prefix" {
  type        = list(string)
  description = "CIDR for the AKS node subnet."
  default     = ["10.0.2.0/24"]
}

///////////////////////////////////////////////////////////
// Route Table (User-Defined Routes)
///////////////////////////////////////////////////////////
variable "route_table_name" {
  type        = string
  description = "Name of the route table for AKS subnet."
  default     = "rt-aks"
}

variable "route_name" {
  type        = string
  description = "Name of the default UDR route."
  default     = "route-default-0-0-0-0"
}

variable "firewall_private_ip" {
  type        = string
  description = "Private IP of your Firewall/NVA for routing."
  default     = "10.0.0.4"
}

///////////////////////////////////////////////////////////
// Private DNS Zone for AKS Private Cluster
///////////////////////////////////////////////////////////
variable "aks_private_dns_zone_name" {
  type        = string
  description = "The Private DNS zone for private AKS (e.g., privatelink.<region>.azmk8s.io)."
  default     = "privatelink.northeurope.azmk8s.io"
}

///////////////////////////////////////////////////////////
// AKS Variables
///////////////////////////////////////////////////////////
variable "aks_cluster_name" {
  type        = string
  description = "Name of the AKS cluster."
  default     = "aks-nih-dev-002"
}

variable "kubernetes_version" {
  type        = string
  description = "AKS Kubernetes version."
  default     = "1.25.6"
}

variable "sku_tier" {
  type        = string
  description = "AKS SKU tier: Free or Paid."
  default     = "Free"
}

variable "automatic_channel_upgrade" {
  type        = string
  description = "The upgrade channel for the AKS cluster."
  default     = "stable"
}

variable "default_node_pool_name" {
  type        = string
  description = "Name of the default node pool."
  default     = "system"
}

variable "default_node_pool_vm_size" {
  type        = string
  description = "VM size for the default node pool."
  default     = "Standard_F8s_v2"
}

variable "default_node_pool_availability_zones" {
  type        = list(string)
  description = "Availability zones for the default node pool."
  default     = ["1", "2", "3"]
}

variable "default_node_pool_enable_auto_scaling" {
  type        = bool
  description = "Enable cluster autoscaler for the default node pool."
  default     = true
}

variable "default_node_pool_enable_host_encryption" {
  type        = bool
  description = "Enable host encryption on node pool VMs."
  default     = false
}

variable "default_node_pool_enable_node_public_ip" {
  type        = bool
  description = "Enable public IP on each node."
  default     = false
}

variable "default_node_pool_max_pods" {
  type        = number
  description = "Max pods per node."
  default     = 50
}

variable "default_node_pool_max_count" {
  type        = number
  description = "Autoscaler max node count."
  default     = 10
}

variable "default_node_pool_min_count" {
  type        = number
  description = "Autoscaler min node count."
  default     = 3
}

variable "default_node_pool_node_count" {
  type        = number
  description = "Initial node count."
  default     = 3
}

variable "default_node_pool_os_disk_type" {
  type        = string
  description = "OS disk type. Usually 'Managed' or 'Ephemeral'."
  default     = "Managed"
}

variable "default_node_pool_node_labels" {
  type        = map(string)
  description = "Key-value labels for default node pool."
  default     = {}
}

variable "default_node_pool_node_taints" {
  type        = list(string)
  description = "Node taints for default node pool."
  default     = []
}

variable "network_plugin" {
  type        = string
  description = "Network plugin: 'azure' or 'kubenet'."
  default     = "azure"
}

variable "network_service_cidr" {
  type        = string
  description = "Service CIDR for cluster services."
  default     = "10.2.0.0/24"
}

variable "network_dns_service_ip" {
  type        = string
  description = "DNS service IP."
  default     = "10.2.0.10"
}

variable "outbound_type" {
  type        = string
  description = "Outbound routing: 'loadBalancer' or 'userDefinedRouting'."
  default     = "userDefinedRouting"
}

variable "role_based_access_control_enabled" {
  type        = bool
  description = "Enable RBAC in AKS."
  default     = true
}

variable "tenant_id" {
  type        = string
  description = "Tenant ID for Azure AD integration."
}

variable "admin_group_object_ids" {
  type        = list(string)
  description = "List of AAD group object IDs for AKS Admin."
  default     = []
}

variable "azure_rbac_enabled" {
  type        = bool
  description = "Enable Azure RBAC."
  default     = true
}

variable "admin_username" {
  type        = string
  description = "Admin username on AKS nodes."
  default     = "azadmin"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key for node access."
}

variable "keda_enabled" {
  type        = bool
  default     = true
}

variable "vertical_pod_autoscaler_enabled" {
  type        = bool
  default     = true
}

variable "workload_identity_enabled" {
  type        = bool
  default     = true
}

variable "oidc_issuer_enabled" {
  type        = bool
  default     = true
}

variable "open_service_mesh_enabled" {
  type        = bool
  default     = true
}

variable "image_cleaner_enabled" {
  type        = bool
  default     = true
}

variable "azure_policy_enabled" {
  type        = bool
  default     = true
}

variable "http_application_routing_enabled" {
  type        = bool
  default     = false
}

///////////////////////////////////////////////////////////
// Log Analytics (disabled / not used)
///////////////////////////////////////////////////////////
variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics workspace id (not used if null)."
  default     = null
}
