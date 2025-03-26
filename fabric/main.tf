terraform {
  required_providers {
    fabric = {
      source  = "microsoft/fabric"
      version = "0.1.0-rc.2"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "1.7.0"
    }
  }
}

provider "fabric" {
  preview = true
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "azurerm" {
  alias           = "hub_subscription"
  subscription_id = var.hub_subscription_id
  features {}
}

//Resource Groups
resource "azurerm_resource_group" "rg" {
  count = var.existing_rg ? 0 : 1

  name     = var.resource_group_name
  location = var.location

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

data "azurerm_resource_group" "rg" {
  count = var.existing_rg ? 1 : 0
  name  = var.resource_group_name
}

resource "azurerm_resource_group" "support_rg" {
  for_each = { for k, v in fabric_workspace.workspaces : k => v }
  name     = "rg-fabric-support-${each.key}-${var.location}-001"
  location = var.location

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_fabric_capacity" "fabric_capacity" {
  name                = var.fabric_capacity_name
  resource_group_name = var.existing_rg ? data.azurerm_resource_group.rg[0].name : azurerm_resource_group.rg[0].name
  location            = var.location

  administration_members = var.fabric_administrators

  sku {
    name = var.sku_name
    tier = "Fabric"
  }

  # tags = {
  #   environment = "test" # You can customize this tag if needed
  # }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

data "fabric_capacity" "capacity" {
  display_name = var.fabric_capacity_name

  depends_on = [azurerm_fabric_capacity.fabric_capacity]
}

resource "fabric_workspace" "workspaces" {
  for_each     = var.fabric_workspaces
  display_name = "fabws_${var.customer_short_name}_${each.key}"
  capacity_id  = data.fabric_capacity.capacity.id
  identity = {
    type = "SystemAssigned"
  }
  depends_on = [azurerm_fabric_capacity.fabric_capacity]
}

resource "fabric_lakehouse" "bronze_lakehouses" {
  for_each = { for k, v in fabric_workspace.workspaces : k => v }

  display_name = "lh_data_platform_${each.key}_bronze"
  workspace_id = each.value.id
}

resource "fabric_lakehouse" "silver_lakehouses" {
  for_each = { for k, v in fabric_workspace.workspaces : k => v }

  display_name = "lh_data_platform_${each.key}_silver"
  workspace_id = each.value.id
}

resource "fabric_warehouse" "gold_warehouses" {
  for_each = { for k, v in fabric_workspace.workspaces : k => v }

  display_name = "wh_data_platform_${each.key}_gold"
  workspace_id = each.value.id
}

resource "fabric_sql_database" "metadata" {
  for_each     = { for k, v in fabric_workspace.workspaces : k => v }
  display_name = "sql_data_platform_${each.key}_metadata"
  workspace_id = each.value.id
}
