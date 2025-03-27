resource "azurerm_resource_provider_registration" "purview" {
  name = "Microsoft.Purview"
}

resource "azurerm_resource_group" "purview_rg" {
  name     = "rg-purview-prod-${var.location}-001"
  location = var.location

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azuread_group" "ans_fabric_purview_authentication" {
  display_name     = "sg_microsoft_fabric_purview_authentication"
  mail_nickname    = "sg_microsoft_fabric_purview_authentication"
  security_enabled = true
}

//Purview Keyvault
resource "azurerm_key_vault" "purview_keyvault" {
  name                = "kvpviewprod${var.location_short}"
  location            = var.location
  resource_group_name = azurerm_resource_group.purview_rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices" # Optional: Allows trusted Azure services to bypass
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    secret_permissions = [
      "Get",
      "List",
      "Set",
    ]
  }

  depends_on = [azurerm_resource_group.purview_rg]

  lifecycle {
    ignore_changes = [
      tags, access_policy
    ]
  }
}

resource "azurerm_key_vault_access_policy" "purview_kv_access" {
  key_vault_id = azurerm_key_vault.purview_keyvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_purview_account.purview_account.identity[0].principal_id

  secret_permissions = [
    "Get",
    "List",
    "Set",
  ]

  certificate_permissions = [
    "Get",
    "List",
    "Update",
  ]

  key_permissions = [
    "Get",
    "List",
    "Update",
  ]

  depends_on = [azurerm_key_vault.purview_keyvault, azurerm_purview_account.purview_account]
}

#Keyvault Private Endpoint
resource "azurerm_private_endpoint" "purview_keyvault_pe" {
  name                = "pep-kvpviewprod${var.location_short}"
  location            = azurerm_key_vault.purview_keyvault.location
  resource_group_name = azurerm_key_vault.purview_keyvault.resource_group_name
  subnet_id           = azurerm_subnet.pep_subnet.id

  private_service_connection {
    name                           = "psc-kvpviewprod${var.location_short}"
    private_connection_resource_id = azurerm_key_vault.purview_keyvault.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  depends_on = [azurerm_key_vault.purview_keyvault, azurerm_subnet.pep_subnet]
}

//Purview Account
resource "azurerm_purview_account" "purview_account" {
  name                = "pview-prod-${var.location}-001"
  resource_group_name = azurerm_resource_group.purview_rg.name
  location            = azurerm_resource_group.purview_rg.location

  identity {
    type = "SystemAssigned"
  }

  managed_resource_group_name = "rg_pview_managed_${var.location}_001"

  depends_on = [azurerm_resource_provider_registration.purview]
}
