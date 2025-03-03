output "fabric_capacity_id" {
  value       = azurerm_fabric_capacity.fabric_capacity.id
  description = "ID of the Fabric capacity"
}

output "fabric_workspace_id" {
  value       = fabric_workspace.example2.id
  description = "ID of the Fabric workspace"
}

# Add other outputs as needed
