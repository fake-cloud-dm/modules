resource "azurerm_powerbi_embedded_capacity" "fabric_capacity" {
  name                = var.fabric_capacity_name
  resource_group_name = var.existing_rg ? data.azurerm_resource_group.rg[0].name : azurerm_resource_group.rg[0].name
  location            = var.location
  sku_name            = var.sku_name
  admin_users         = var.admin_users
}

resource "azurerm_powerbi_embedded_workspace" "fabric_workspace" {
  name                = var.fabric_workspace_name
  capacity_id         = azurerm_powerbi_embedded_capacity.fabric_capacity.id
  resource_group_name = var.existing_rg ? data.azurerm_resource_group.rg[0].name : azurerm_resource_group.rg[0].name
}

# Add resources for VNet, Private Link, etc., if needed
