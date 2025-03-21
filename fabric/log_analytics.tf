resource "azurerm_log_analytics_workspace" "workspace_loganalytics" {
  for_each            = fabric_workspace.workspaces
  name                = "log-fabric-${each.key}-${var.location_short}-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.support_rg[each.key].name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_analytics_retention

  depends_on = [azurerm_resource_group.support_rg]
}

resource "azurerm_monitor_diagnostic_setting" "workspace_diagnostic_setting" {
  for_each                   = fabric_workspace.workspaces
  name                       = "fabric_diagnostic_setting_${each.key}"
  target_resource_id         = "/subscriptions/${data.azurerm_subscription.current.id}/resourceGroups/${azurerm_resource_group.support_rg[each.key].name}/providers/Microsoft.PowerBIDedicated/capacities/${data.fabric_capacity.capacity.name}/workspaces/${fabric_workspace.workspaces[each.key].name}"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace_loganalytics[each.key].id

  enabled_log {
    category = "AuditEvent"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }

  depends_on = [azurerm_log_analytics_workspace.workspace_loganalytics, fabric_workspace.workspaces]
}
