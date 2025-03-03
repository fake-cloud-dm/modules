output "fabric_capacity_id" {
  value       = azurerm_powerbi_capacity.fabric_capacity.id
  description = "ID of the Fabric capacity"
}

output "fabric_workspace_id" {
  value       = azurerm_powerbi_workspace.fabric_workspace.id
  description = "ID of the Fabric workspace"
}

# Add other outputs as needed
