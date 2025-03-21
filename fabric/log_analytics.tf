resource "azurerm_log_analytics_workspace" "workspace_loganalytics" {
  for_each            = fabric_workspace.workspaces
  name                = "log-fabric-${each.key}-${var.location_short}-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.support_rg[each.key].name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_analytics_retention_days

  depends_on = [azurerm_resource_group.support_rg]
}
