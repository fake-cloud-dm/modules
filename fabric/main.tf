resource "azurerm_fabric_capacity" "fabric_capacity" {
  name                = var.fabric_capacity_name
  resource_group_name = var.existing_rg ? data.azurerm_resource_group.rg[0].name : azurerm_resource_group.rg[0].name
  location            = var.location

  administration_members = var.admin_users

  sku {
    name = var.sku_name
    tier = "Fabric"
  }

  tags = {
    environment = "test" # You can customize this tag if needed
  }
}

resource "azurerm_powerbi_workspace" "fabric_workspace" {
  name                = var.fabric_workspace_name
  capacity_id         = azurerm_fabric_capacity.fabric_capacity.id
  resource_group_name = var.existing_rg ? data.azurerm_resource_group.rg[0].name : azurerm_resource_group.rg[0].name
}

# Add resources for VNet, Private Link, etc., if needed
