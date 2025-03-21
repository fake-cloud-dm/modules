variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "existing_rg" {
  type        = bool
  description = "Whether to use an existing resource group"
  default     = false
}

variable "existing_rg_name" {
  type        = string
  description = "Name of the existing resource group (if existing_rg is true)"
  default     = ""
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region to deploy resources"
  default     = "UK South"
}

variable "location_short" {
  type        = string
  description = "Short name of the Azure region"
  default     = "uks"
}

variable "fabric_capacity_name" {
  type        = string
  description = "Name of the Fabric capacity"
}

variable "sku_name" {
  type        = string
  description = "Fabric capacity SKU"
  default     = "F8"
}

variable "fabric_administrators" {
  type        = list(string)
  description = "List of Fabric admin users' email addresses"
}

variable "fabric_workspaces" {
  type = map(object({
  }))
  description = "Map of Fabric workspaces to create"
  default     = {}
}

variable "azuredevops_org" {
  type        = string
  description = "Azure DevOps organization"
}

variable "azuredevops_pat" {
  type        = string
  description = "Azure DevOps Personal Access Token"
  sensitive   = true
}

variable "customer_short_name" {
  type        = string
  description = "Short name of the customer"
}

variable "log_analytics_sku" {
  type        = string
  description = "Log Analytics SKU"
  default     = "PerGB2018"

}

variable "log_analytics_retention" {
  description = "Log Analytics retention days"
  default     = 30
}

variable "gw_subnet_prefixes" {
  type        = list(string)
  description = "Gateway subnet prefixes"
}

variable "vnet_address_space" {
  type        = list(string)
  description = "Address space for the virtual network"
}

variable "hub_subscription_id" {
  type        = string
  description = "Subscription ID of the hub network"
}

variable "hub_vnet_rg" {
  type        = string
  description = "Name of the hub resource group"
}

variable "hub_vnet_name" {
  type        = string
  description = "Name of the hub network"
}

variable "hub_fw_ip" {
  type        = string
  description = "IP address of the hub firewall"
}
