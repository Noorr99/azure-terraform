########################################
# In Use (Referenced in main.tf)
########################################

variable "location" {
  description = "Specifies the location for the resource group and all the resources"
  default     = "westeurope" # Changed to a potentially less expensive region
  type        = string
}

variable "resource_group_name" {
  description = "Specifies the resource group name"
  default     = "BaboRG"
  type        = string
}

variable "tags" {
  description = "(Optional) Specifies tags for all the resources"
  default     = {
    createdWith = "Terraform"
  }
}

variable "aks_vnet_name" {
  description = "Specifies the name of the AKS VNet"
  default     = "AksVNet"
  type        = string
}

variable "aks_vnet_address_space" {
  description = "Specifies the address space of the AKS VNet"
  default     = ["10.0.0.0/24"] # Reduced address space for lower costs
  type        = list(string)
}

variable "vm_subnet_name" {
  description = "Specifies the name of the jumpbox subnet"
  default     = "VmSubnet"
  type        = string
}

variable "vm_subnet_address_prefix" {
  description = "Specifies the address prefix of the jumpbox subnet"
  default     = ["10.0.1.0/28"] # Smaller subnet for cost-effectiveness
  type        = list(string)
}

variable "storage_account_kind" {
  description = "(Optional) Specifies the account kind of the storage account"
  default     = "Storage" # Downgraded to basic storage
  type        = string
}

variable "storage_account_tier" {
  description = "(Optional) Specifies the account tier of the storage account"
  default     = "Standard" # Standard tier retained for cost savings
  type        = string
}

variable "storage_account_replication_type" {
  description = "(Optional) Specifies the replication type of the storage account"
  default     = "LRS" # Local redundancy for minimal costs
  type        = string
}

variable "acr_name" {
  description = "Specifies the name of the container registry"
  type        = string
  default     = "BaboAcr"
}

variable "acr_sku" {
  description = "Specifies the SKU of the container registry"
  type        = string
  default     = "Basic" # Changed to Basic SKU for lower cost
}

variable "acr_admin_enabled" {
  description = "Specifies whether admin is enabled for the container registry"
  type        = bool
  default     = true
}

variable "acr_georeplication_locations" {
  description = "(Optional) A list of Azure locations where the container registry should be geo-replicated."
  type        = list(string)
  default     = []
}

variable "key_vault_name" {
  description = "Specifies the name of the key vault."
  type        = string
  default     = "BaboAksKeyVault"
}

variable "key_vault_sku_name" {
  description = "(Required) The Name of the SKU used for this Key Vault."
  type        = string
  default     = "standard" # Retained standard for cost optimization
}

variable "key_vault_enabled_for_deployment" {
  description = "(Optional) Boolean flag to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault. Defaults to false."
  type        = bool
  default     = true
}

variable "key_vault_enabled_for_disk_encryption" {
  description = "(Optional) Boolean flag to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys. Defaults to false."
  type        = bool
  default     = true
}

variable "key_vault_enabled_for_template_deployment" {
  description = "(Optional) Boolean flag to specify whether Azure Resource Manager is permitted to retrieve secrets from the key vault. Defaults to false."
  type        = bool
  default     = true
}

variable "key_vault_enable_rbac_authorization" {
  description = "(Optional) Boolean flag to specify whether Azure Key Vault uses Role Based Access Control (RBAC)."
  type        = bool
  default     = false # Disabled RBAC for simplicity and cost reduction
}

variable "key_vault_purge_protection_enabled" {
  description = "(Optional) Is Purge Protection enabled for this Key Vault?"
  type        = bool
  default     = false # Disabled for cost-saving
}

variable "key_vault_soft_delete_retention_days" {
  description = "(Optional) The number of days that items should be retained for once soft-deleted."
  type        = number
  default     = 7 # Minimum retention days for reduced cost
}

variable "key_vault_bypass" { 
  description = "(Required) Specifies which traffic can bypass the network rules. Possible values are AzureServices and None."
  type        = string
  default     = "AzureServices"
}

variable "key_vault_default_action" { 
  description = "(Required) The Default Action when no rules match. Possible values are Allow and Deny."
  type        = string
  default     = "Allow"
}

variable "vm_name" {
  description = "Specifies the name of the jumpbox virtual machine"
  default     = "TestVm"
  type        = string
}

variable "vm_public_ip" {
  description = "(Optional) Specifies whether to create a public IP for the VM"
  type        = bool
  default     = false
}

variable "vm_size" {
  description = "Specifies the size of the jumpbox virtual machine"
  default     = "Standard_B1s" # Changed to a smaller, cost-effective VM size
  type        = string
}

variable "admin_username" {
  description = "(Required) Specifies the admin username of the VM"
  type        = string
  default     = "azadmin"
}

variable "ssh_public_key" {
  description = "(Required) Specifies the SSH public key for the jumpbox virtual machine"
  type        = string
}

variable "domain_name_label" {
  description = "Specifies the domain name for the jumpbox VM's public IP"
  default     = "babotestvm"
  type        = string
}

variable "vm_os_disk_storage_account_type" {
  description = "Specifies the storage account type of the OS disk"
  default     = "Standard_LRS" # Switched to standard locally redundant storage
  type        = string
}

variable "vm_os_disk_image" {
  type        = map(string)
  description = "Specifies the OS disk image of the VM"
  default     = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS" # Older, stable version for potentially lower cost
    version   = "latest"
  }
}


########################################
# Commented Out (Not Used in main.tf)
########################################

 variable "log_analytics_workspace_name" {
   description = "Specifies the name of the log analytics workspace"
   default     = "BaboAksWorkspace"
   type        = string
 }

 variable "log_analytics_retention_days" {
   description = "Specifies the number of days of the retention policy"
   type        = number
   default     = 30
 }

# variable "solution_plan_map" {
#   description = "Specifies solutions to deploy to log analytics workspace"
#   default     = {
#     ContainerInsights= {
#       product   = "OMSGallery/ContainerInsights"
#       publisher = "Microsoft"
#     }
#   }
#   type = map(any)
# }

# variable "hub_vnet_name" {
#   description = "Specifies the name of the hub virtual virtual network"
#   default     = "HubVNet"
#   type        = string
# }

# variable "hub_address_space" {
#   description = "Specifies the address space of the hub virtual virtual network"
#   default     = ["10.1.0.0/16"]
#   type        = list(string)
# }

# variable "hub_firewall_subnet_address_prefix" {
#   description = "Specifies the address prefix of the firewall subnet"
#   default     = ["10.1.0.0/24"]
#   type        = list(string)
# }

# variable "hub_bastion_subnet_address_prefix" {
#   description = "Specifies the address prefix of the firewall subnet"
#   default     = ["10.1.1.0/24"]
#   type        = list(string)
# }

# variable "aks_cluster_name" {
#   description = "(Required) Specifies the name of the AKS cluster."
#   default     = "BaboAks"
#   type        = string
# }

# variable "role_based_access_control_enabled" {
#   description = "(Required) Is Role Based Access Control Enabled?"
#   default     = true
#   type        = bool
# }

# variable "automatic_channel_upgrade" {
#   description = "(Optional) The upgrade channel for this Kubernetes Cluster."
#   default     = "stable"
#   type        = string
#
#   validation {
#     condition     = contains(["patch", "rapid", "stable"], var.automatic_channel_upgrade)
#     error_message = "The upgrade mode is invalid."
#   }
# }

# variable "admin_group_object_ids" {
#   description = "(Optional) A list of Object IDs of Microsoft Entra ID Groups which should have Admin Role on the Cluster."
#   default     = ["6e5de8c1-5a4b-409b-994f-0706e4403b77", "78761057-c58c-44b7-aaa7-ce1639c6c4f5"]
#   type        = list(string)
# }

# variable "azure_rbac_enabled" {
#   description = "(Optional) Is Role Based Access Control based on Microsoft Entra ID enabled?"
#   default     = true
#   type        = bool
# }

# variable "sku_tier" {
#   description = "(Optional) The SKU Tier for the Kubernetes Cluster."
#   default     = "Free"
#   type        = string
#
#   validation {
#     condition     = contains(["Free", "Paid"], var.sku_tier)
#     error_message = "The sku tier is invalid."
#   }
# }

# variable "kubernetes_version" {
#   description = "Specifies the AKS Kubernetes version"
#   default     = "1.21.1"
#   type        = string
# }

# variable "default_node_pool_vm_size" {
#   description = "Specifies the vm size of the default node pool"
#   default     = "Standard_F8s_v2"
#   type        = string
# }

# variable "default_node_pool_availability_zones" {
#   description = "Specifies the availability zones of the default node pool"
#   default     = ["1", "2", "3"]
#   type        = list(string)
# }

# variable "network_dns_service_ip" {
#   description = "Specifies the DNS service IP"
#   default     = "10.2.0.10"
#   type        = string
# }

# variable "network_service_cidr" {
#   description = "Specifies the service CIDR"
#   default     = "10.2.0.0/24"
#   type        = string
# }

# variable "network_plugin" {
#   description = "Specifies the network plugin of the AKS cluster"
#   default     = "azure"
#   type        = string
# }

# variable "pod_subnet_name" {
#   description = "Specifies the name of the pod subnet."
#   default     = "PodSubnet"
#   type        = string
# }

# variable "pod_subnet_address_prefix" {
#   description = "Specifies the address prefix of the pod subnet"
#   type        = list(string)
#   default     = ["10.0.32.0/20"]
# }

# variable "default_node_pool_name" {
#   description = "Specifies the name of the default node pool"
#   default     = "system"
#   type        = string
# }

# variable "default_node_pool_subnet_name" {
#   description = "Specifies the name of the subnet that hosts the default node pool"
#   default     = "SystemSubnet"
#   type        = string
# }

# variable "default_node_pool_subnet_address_prefix" {
#   description = "Specifies the address prefix of the subnet that hosts the default node pool"
#   default     = ["10.0.0.0/20"]
#   type        = list(string)
# }

# variable "default_node_pool_enable_auto_scaling" {
#   description = "(Optional) Whether to enable auto-scaler. Defaults to true."
#   type        = bool
#   default     = true
# }

# variable "default_node_pool_enable_host_encryption" {
#   description = "(Optional) Should the nodes have host encryption enabled? Defaults to false."
#   type        = bool
#   default     = false
# }

# variable "default_node_pool_enable_node_public_ip" {
#   description = "(Optional) Should each node have a Public IP? Defaults to false."
#   type        = bool
#   default     = false
# }

# variable "default_node_pool_max_pods" {
#   description = "(Optional) The maximum number of pods on each agent."
#   type        = number
#   default     = 50
# }

# variable "system_node_pool_node_labels" {
#   description = "(Optional) A map of Kubernetes labels for nodes in this Node Pool."
#   type        = map(any)
#   default     = {}
# }

# variable "system_node_pool_node_taints" {
#   description = "(Optional) A list of Kubernetes taints for nodes in the agent pool."
#   type        = list(string)
#   default     = ["CriticalAddonsOnly=true:NoSchedule"]
# }

# variable "default_node_pool_os_disk_type" {
#   description = "(Optional) The type of disk for the Operating System. e.g., Ephemeral or Managed."
#   type        = string
#   default     = "Ephemeral"
# }

# variable "default_node_pool_max_count" {
#   description = "(Required) The maximum number of nodes."
#   type        = number
#   default     = 10
# }

# variable "default_node_pool_min_count" {
#   description = "(Required) The minimum number of nodes."
#   type        = number
#   default     = 3
# }

# variable "default_node_pool_node_count" {
#   description = "(Optional) The initial number of nodes."
#   type        = number
#   default     = 3
# }

# variable "additional_node_pool_subnet_name" {
#   description = "Specifies the name of the subnet that hosts the additional node pool"
#   default     = "UserSubnet"
#   type        = string
# }

# variable "additional_node_pool_subnet_address_prefix" {
#   description = "Specifies the address prefix of the subnet that hosts the additional node pool"
#   type        = list(string)
#   default     = ["10.0.16.0/20"]
# }

# variable "additional_node_pool_name" {
#   description = "(Required) Specifies the name of the additional node pool."
#   type        = string
#   default     = "user"
# }

# variable "additional_node_pool_vm_size" {
#   description = "(Required) The SKU for the VMs in this Node Pool."
#   type        = string
#   default     = "Standard_F8s_v2"
# }

# variable "additional_node_pool_availability_zones" {
#   description = "(Optional) A list of Availability Zones."
#   type        = list(string)
#   default     = ["1", "2", "3"]
# }

# variable "additional_node_pool_enable_auto_scaling" {
#   description = "(Optional) Whether to enable auto-scaler. Defaults to false."
#   type        = bool
#   default     = true
# }

# variable "additional_node_pool_enable_host_encryption" {
#   description = "(Optional) Enable host encryption? Defaults to false."
#   type        = bool
#   default     = false
# }

# variable "additional_node_pool_enable_node_public_ip" {
#   description = "(Optional) Should each node have a Public IP? Defaults to false."
#   type        = bool
#   default     = false
# }

# variable "additional_node_pool_max_pods" {
#   description = "(Optional) The maximum number of pods that can run on each agent."
#   type        = number
#   default     = 50
# }

# variable "additional_node_pool_mode" {
#   description = "(Optional) Use for System or User resources? Defaults to User."
#   type        = string
#   default     = "User"
# }

# variable "additional_node_pool_node_labels" {
#   description = "(Optional) A map of Kubernetes labels."
#   type        = map(any)
#   default     = {}
# }

# variable "additional_node_pool_node_taints" {
#   description = "(Optional) A list of Kubernetes taints."
#   type        = list(string)
#   default     = []
# }

# variable "additional_node_pool_os_disk_type" {
#   description = "(Optional) Type of the OS disk. e.g., Ephemeral or Managed."
#   type        = string
#   default     = "Ephemeral"
# }

# variable "additional_node_pool_os_type" {
#   description = "(Optional) The Operating System for this Node Pool."
#   type        = string
#   default     = "Linux"
# }

# variable "additional_node_pool_priority" {
#   description = "(Optional) VM priority. e.g., Regular or Spot."
#   type        = string
#   default     = "Regular"
# }

# variable "additional_node_pool_max_count" {
#   description = "(Required) The maximum number of nodes."
#   type        = number
#   default     = 10
# }

# variable "additional_node_pool_min_count" {
#   description = "(Required) The minimum number of nodes."
#   type        = number
#   default     = 3
# }

# variable "additional_node_pool_node_count" {
#   description = "(Optional) The initial number of nodes."
#   type        = number
#   default     = 3
# }

# variable "firewall_name" {
#   description = "Specifies the name of the Azure Firewall"
#   default     = "BaboFirewall"
#   type        = string
# }

# variable "firewall_sku_name" {
#   description = "(Required) SKU name of the Firewall."
#   default     = "AZFW_VNet"
#   type        = string
#
#   validation {
#     condition     = contains(["AZFW_Hub", "AZFW_VNet"], var.firewall_sku_name)
#     error_message = "The value of the sku name property of the firewall is invalid."
#   }
# }

# variable "firewall_sku_tier" {
#   description = "(Required) SKU tier of the Firewall."
#   default     = "Standard"
#   type        = string
#
#   validation {
#     condition     = contains(["Premium", "Standard", "Basic"], var.firewall_sku_tier)
#     error_message = "The value of the sku tier property of the firewall is invalid."
#   }
# }

# variable "firewall_threat_intel_mode" {
#   description = "(Optional) The operation mode for threat intelligence-based filtering."
#   default     = "Alert"
#   type        = string
#
#   validation {
#     condition     = contains(["Off", "Alert", "Deny"], var.firewall_threat_intel_mode)
#     error_message = "The threat intel mode is invalid."
#   }
# }

# variable "firewall_zones" {
#   description = "Specifies the availability zones of the Azure Firewall"
#   default     = ["1", "2", "3"]
#   type        = list(string)
# }

# variable "bastion_host_name" {
#   description = "(Optional) Specifies the name of the bastion host"
#   default     = "BaboBastionHost"
#   type        = string
# }

# variable "script_storage_account_name" {
#   description = "(Optional) Storage Account name containing the custom script."
#   type        = string
# }

# variable "script_storage_account_key" {
#   description = "(Optional) Storage Account key containing the custom script."
#   type        = string
# }

# variable "container_name" {
#   description = "(Optional) Container name that has the custom script."
#   type        = string
#   default     = "scripts"
# }

# variable "script_name" {
#   description = "(Optional) Name of the custom script."
#   type        = string
#   default     = "configure-jumpbox-vm.sh"
# }

# variable "keda_enabled" {
#   description = "(Optional) Specifies whether KEDA Autoscaler is enabled."
#   type        = bool
#   default     = true
# }

# variable "vertical_pod_autoscaler_enabled" {
#   description = "(Optional) Specifies whether VPA should be enabled."
#   type        = bool
#   default     = true
# }

# variable "workload_identity_enabled" {
#   description = "(Optional) Specifies whether Microsoft Entra ID Workload Identity is enabled."
#   type        = bool
#   default     = true
# }

# variable "oidc_issuer_enabled" {
#   description = "(Optional) Enable or Disable the OIDC issuer URL."
#   type        = bool
#   default     = true
# }

# variable "open_service_mesh_enabled" {
#   description = "(Optional) Is Open Service Mesh enabled?"
#   type        = bool
#   default     = true
# }

# variable "image_cleaner_enabled" {
#   description = "(Optional) Specifies whether Image Cleaner is enabled."
#   type        = bool
#   default     = true
# }

# variable "azure_policy_enabled" {
#   description = "(Optional) Should the Azure Policy Add-On be enabled?"
#   type        = bool
#   default     = true
# }

# variable "http_application_routing_enabled" {
#   description = "(Optional) Should HTTP Application Routing be enabled?"
#   type        = bool
#   default     = false
# }
