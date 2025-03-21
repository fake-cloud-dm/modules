resource "azurerm_key_vault" "workspace_keyvault" {
  for_each            = fabric_workspace.workspaces
  name                = "kvfabws${var.customer_short_name}${each.key}"
  location            = var.location
  resource_group_name = azurerm_resource_group.support_rg[each.key].name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
    ]
    key_permissions = [
      "Get",
      "Create",
      "Delete",
      "List",
      "Recover",
      "Release",
      "Purge",
      "Sign",
      "Verify",
      "WrapKey",
      "UnwrapKey",
    ]
    storage_permissions = [
      "Get",
      "List",
      "Delete",
      "Set",
      "Recover",
      "Backup",
      "Restore",
      "Purge",
    ]
  }

  depends_on = [azurerm_resource_group.support_rg]
}
