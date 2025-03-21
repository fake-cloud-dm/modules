output "fabric_capacity_id" {
  value       = azurerm_fabric_capacity.fabric_capacity.id
  description = "ID of the Fabric capacity"
}

output "fabric_workspace_ids" {
  value       = { for key, workspace in fabric_workspace.workspaces : key => workspace.id }
  description = "IDs of the Fabric workspaces"
}

# Add other outputs as needed
