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
  object_id    = azurerm_purview_account.purview_account.identity.principal_id

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

//Purview Account
resource "azurerm_purview_account" "purview_account" {
  name                = "pview-prod-${var.location}-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  identity {
    type = "SystemAssigned"
  }
}
