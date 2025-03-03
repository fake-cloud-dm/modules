# provider "fabric" {
#   source = "microsoft/fabric"
#   # Configuration options for the Fabric provider, if needed
# }

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

resource "fabric_workspace" "example2" {
  display_name = "example2"
  description  = "Example Workspace 2"
  capacity_id  = azurerm_fabric_capacity.fabric_capacity.id
  identity = {
    type = "SystemAssigned"
  }
}

# Add resources for VNet, Private Link, etc., if needed
