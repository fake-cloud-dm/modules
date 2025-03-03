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

# Add more variables as needed (e.g., for VNet configuration, Private Link)
