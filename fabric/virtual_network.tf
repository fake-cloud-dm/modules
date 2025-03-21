# Virtual Network
resource "azurerm_virtual_network" "fabric_vnet" {
  name                = "vnet-fabric-prod-${var.location_short}-001"
  resource_group_name = var.existing_rg ? data.azurerm_resource_group.rg[0].name : azurerm_resource_group.rg[0].name
  location            = var.location
  address_space       = var.vnet_address_space

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

# Subnet for Gateway
resource "azurerm_subnet" "gateway_subnet" {
  name                 = "snet-fabric-gw-prod-uks-001"
  resource_group_name  = var.existing_rg ? data.azurerm_resource_group.rg[0].name : azurerm_resource_group.rg[0].name
  virtual_network_name = azurerm_virtual_network.fabric_vnet.name
  address_prefixes     = var.gw_subnet_prefixes

  delegation {
    name = "Microsoft.PowerPlatformDelegation"
    service_delegation {
      name = "Microsoft.PowerPlatform/vnetaccesslinks"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

# Fabric Virtual Network Gateway
resource "fabric_gateway" "fabric_vnet_gateway" {
  type                            = "VirtualNetwork"
  display_name                    = "fabric-vnet-gw-prod-${var.location_short}-001"
  inactivity_minutes_before_sleep = 30 # Adjust as needed
  number_of_member_gateways       = 1
  virtual_network_azure_resource = {
    resource_group_name  = var.existing_rg ? data.azurerm_resource_group.rg[0].name : azurerm_resource_group.rg[0].name
    virtual_network_name = azurerm_virtual_network.fabric_vnet.name
    subnet_name          = azurerm_subnet.gateway_subnet.name
    subscription_id      = var.subscription_id
  }
  capacity_id = data.fabric_capacity.capacity.id

  depends_on = [azurerm_virtual_network.fabric_vnet, azurerm_subnet.gateway_subnet]
}
