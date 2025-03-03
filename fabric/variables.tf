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

variable "fabric_capacity_name" {
  type        = string
  description = "Name of the Fabric capacity"
}

variable "sku_name" {
  type        = string
  description = "Fabric capacity SKU"
  default     = "F8"
}

variable "admin_users" {
  type        = list(string)
  description = "List of Fabric admin users' email addresses"
}

variable "fabric_workspace_name" {
  type        = string
  description = "Name of the Fabric workspace"
}

variable "fabric_workspaces" {
  type = map(object({
    display_name = string
    description  = string
  }))
  description = "Map of Fabric workspaces to create"
  default     = {}
}

# Add more variables as needed (e.g., for VNet configuration, Private Link)
