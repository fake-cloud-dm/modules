data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "workspace_keyvault" {
  for_each            = fabric_workspace.workspaces
  name                = "kvfabws${var.customer_short_name}${each.key}"
  location            = var.location
  resource_group_name = azurerm_resource_group.support_rg[each.key].name
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

  depends_on = [azurerm_resource_group.support_rg]

  lifecycle {
    ignore_changes = [
      tags, access_policy
    ]
  }
}

resource "azurerm_key_vault_access_policy" "workspace_kv_access" {
  for_each     = fabric_workspace.workspaces
  key_vault_id = azurerm_key_vault.workspace_keyvault[each.key].id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = fabric_workspace.workspaces[each.key].identity.service_principal_id

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

  depends_on = [azurerm_key_vault.workspace_keyvault, fabric_workspace.workspaces]
}

resource "azurerm_key_vault_access_policy" "ans_engineer_kv_access" {
  for_each     = fabric_workspace.workspaces
  key_vault_id = azurerm_key_vault.workspace_keyvault[each.key].id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azuread_group.ans_engineer_fabric_admin.object_id

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

  depends_on = [azuread_group.ans_engineer_fabric_admin]
}

#Keyvault Private Endpoints
resource "azurerm_private_endpoint" "workspace_keyvault_pe" {
  for_each            = azurerm_key_vault.workspace_keyvault
  name                = "pep-kvfabws-${var.customer_short_name}-${each.key}"
  location            = azurerm_key_vault.workspace_keyvault[each.key].location
  resource_group_name = azurerm_key_vault.workspace_keyvault[each.key].resource_group_name
  subnet_id           = azurerm_subnet.pep_subnet.id

  private_service_connection {
    name                           = "psc-kvfabws-${var.customer_short_name}-${each.key}"
    private_connection_resource_id = azurerm_key_vault.workspace_keyvault[each.key].id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  depends_on = [azurerm_key_vault.workspace_keyvault, azurerm_subnet.pep_subnet]
}
