terraform {
  required_providers {
    fabric = {
      source  = "microsoft/fabric"
      version = "~> 0.1.0-beta.10"
    }
  }
}

resource "azurerm_resource_group" "rg" {
  count = var.existing_rg ? 0 : 1

  name     = var.resource_group_name
  location = var.location
}

data "azurerm_resource_group" "rg" {
  count = var.existing_rg ? 1 : 0

  name = var.existing_rg_name
}

resource "azurerm_fabric_capacity" "fabric_capacity" {
  name                = var.fabric_capacity_name
  resource_group_name = var.existing_rg ? data.azurerm_resource_group.rg[0].name : azurerm_resource_group.rg[0].name
  location            = var.location

  administration_members = var.admin_users

  sku {
    name = var.sku_name
    tier = "Fabric"
  }

  tags = {
    environment = "test" # You can customize this tag if needed
  }
}

resource "fabric_workspace" "workspaces" {
  for_each     = var.fabric_workspaces
  display_name = "fabws-${each.key}-uks001"
  capacity_id  = azurerm_fabric_capacity.fabric_capacity.id
  identity = {
    type = "SystemAssigned"
  }
}

resource "azuread_group" "workspace_groups" {
  for_each = {
    for workspace_key, workspace in fabric_workspace.workspaces :
    workspace_key => {
      for role in ["admin", "contributor", "member", "viewer"] :
      role => {
        display_name = "${workspace.display_name}-${role}"
      }
    }
  }

  display_name     = each.value.display_name
  mail_nickname    = each.value.display_name
  security_enabled = true
}

# resource "fabric_workspace_role_assignment" "role_assignments" {
#   for_each = {
#     for workspace_key, workspace in var.fabric_workspaces :
#     workspace_key => {
#       admin_id        = var.principal_ids[workspace_key].admin_id
#       contributor_id = var.principal_ids[workspace_key].contributor_id
#       member_id       = var.principal_ids[workspace_key].member_id
#       viewer_id       = var.principal_ids[workspace_key].viewer_id
#     }
#   }

#   depends_on = [azuread_group.workspace_groups]

#   dynamic "role_assignment" {
#     for_each = {
#       Admin        = each.value.admin_id,
#       Contributor = each.value.contributor_id,
#       Member       = each.value.member_id,
#       Viewer       = each.value.viewer_id
#     }
#     content {
#       workspace_id  = fabric_workspace.workspaces[each.key].id
#       principal_id  = role_assignment.value
#       principal_type = "Group"
#       role           = role_assignment.key
#     }
#   }
# }

# Add resources for VNet, Private Link, etc., if needed

# resource "fabric_workspace_git" "git_integration" {
#   workspace_id            = "00000000-0000-0000-0000-000000000000"
#   initialization_strategy = "PreferWorkspace"
#   git_provider_details = {
#     git_provider_type = "AzureDevOps"
#     organization_name = "MyExampleOrg"
#     project_name      = "MyExampleProject"
#     repository_name   = "ExampleRepo"
#     branch_name       = "ExampleBranch"
#     directory_name    = "/ExampleDirectory"
#   }
# }
