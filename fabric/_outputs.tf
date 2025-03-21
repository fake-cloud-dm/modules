output "fabric_capacity_id" {
  value       = azurerm_fabric_capacity.fabric_capacity.id
  description = "ID of the Fabric capacity"
}

output "fabric_workspace_ids" {
  value       = { for key, workspace in fabric_workspace.workspaces : key => workspace.id }
  description = "IDs of the Fabric workspaces"
}

output "workspace_principal_ids" {
  value = {
    for key, workspace in fabric_workspace.workspaces : key => workspace.identity != null ? workspace.identity.principal_id : null
  }
}
# Add other outputs as needed
