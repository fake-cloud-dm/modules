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

variable "log_analytics_retention_days" {
  description = "Log Analytics retention days"
  default     = 30
}
