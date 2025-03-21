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
    name = "Microsoft.PowerPlatform/vnetaccesslinks"
    service_delegation {
      name = "Microsoft.PowerPlatform/vnetaccesslinks"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

#Peering to Hub Network
resource "azurerm_virtual_network_peering" "hub_to_fabric_uksouth" {
  name                         = "peer-${var.hub_vnet_name}-to-${azurerm_virtual_network.fabric_vnet.name}"
  resource_group_name          = var.hub_vnet_rg
  virtual_network_name         = var.hub_vnet_name
  remote_virtual_network_id    = azurerm_virtual_network.fabric_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "fabric_to_hub_uksouth" {
  name                         = "peer-${azurerm_virtual_network.fabric_vnet.name}-to-${var.hub_vnet_name}"
  resource_group_name          = var.existing_rg ? data.azurerm_resource_group.rg[0].name : azurerm_resource_group.rg[0].name
  virtual_network_name         = azurerm_virtual_network.fabric_vnet.name
  remote_virtual_network_id    = data.azurerm_virtual_network.hub_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}

data "azurerm_virtual_network" "hub_vnet" {
  name                = var.hub_vnet_name
  resource_group_name = var.hub_vnet_rg
}

#Route Table to Hub Firewall
resource "azurerm_route_table" "route_table_fabric" {
  name                = lower("rt-${azurerm_subnet.gateway_subnet.name}")
  location            = var.location
  resource_group_name = var.existing_rg ? data.azurerm_resource_group.rg[0].name : azurerm_resource_group.rg[0].name

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_route" "rt_fabric_route" {
  name                = "Default"
  resource_group_name = var.existing_rg ? data.azurerm_resource_group.rg[0].name : azurerm_resource_group.rg[0].name
  route_table_name    = azurerm_route_table.route_table_fabric.name

  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.hub_fw_ip
}

resource "azurerm_subnet_route_table_association" "rt_association_connectivity" {
  subnet_id      = azurerm_subnet.gateway_subnet.id
  route_table_id = azurerm_route_table.route_table_fabric.id
}


# # Fabric Virtual Network Gateway
# resource "fabric_gateway" "fabric_vnet_gateway" {
#   type                            = "VirtualNetwork"
#   display_name                    = "fabric-vnet-gw-prod-${var.location_short}-001"
#   inactivity_minutes_before_sleep = 30 # Adjust as needed
#   number_of_member_gateways       = 1
#   virtual_network_azure_resource = {
#     resource_group_name  = var.existing_rg ? data.azurerm_resource_group.rg[0].name : azurerm_resource_group.rg[0].name
#     virtual_network_name = azurerm_virtual_network.fabric_vnet.name
#     subnet_name          = azurerm_subnet.gateway_subnet.name
#     subscription_id      = var.subscription_id
#   }
#   capacity_id = data.fabric_capacity.capacity.id

#   depends_on = [azurerm_virtual_network.fabric_vnet, azurerm_subnet.gateway_subnet]
# }
