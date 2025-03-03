terraform {
  required_providers {
    fabric = {
      source  = "microsoft/fabric"
      version = "~> 0.1.0-beta.10"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "1.7.0"
    }
  }
}

provider "fabric" {
  preview = true
}

provider "azuredevops" {
  org_service_url       = "https://dev.azure.com/${var.azuredevops_org}"
  personal_access_token = var.azuredevops_pat
}

resource "azurerm_resource_group" "rg" {
  count = var.existing_rg ? 0 : 1

  name     = var.resource_group_name
  location = var.location
}

data "azurerm_resource_group" "rg" {
  count = var.existing_rg ? 1 : 0

  name = var.resource_group_name
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

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

data "fabric_capacity" "capacity" {
  display_name = var.fabric_capacity_name

  depends_on = [azurerm_fabric_capacity.fabric_capacity]
}

resource "fabric_workspace" "workspaces" {
  for_each     = var.fabric_workspaces
  display_name = "fabws-${each.key}-uks001"
  capacity_id  = data.fabric_capacity.capacity.id
  identity = {
    type = "SystemAssigned"
  }
  depends_on = [azurerm_fabric_capacity.fabric_capacity]
}

resource "fabric_lakehouse" "bronze_lakehouses" {
  for_each = { for k, v in fabric_workspace.workspaces : k => v }

  display_name = "fabwslh-${each.key}-bronze"
  workspace_id = each.value.id
}

resource "fabric_lakehouse" "silver_lakehouses" {
  for_each = { for k, v in fabric_workspace.workspaces : k => v }

  display_name = "fabwslh-${each.key}-silver"
  workspace_id = each.value.id
}

resource "fabric_warehouse" "golden_warehouses" {
  for_each = { for k, v in fabric_workspace.workspaces : k => v }

  display_name = "fabwswh-${each.key}-golden"
  workspace_id = each.value.id
}

# resource "azuread_group" "admin_groups" {
#   for_each = { for k, v in fabric_workspace.workspaces : k => v.display_name }

#   display_name     = "${each.value}-admin"
#   mail_nickname    = "${each.value}-admin"
#   security_enabled = true
# }

# resource "azuread_group" "contributor_groups" {
#   for_each = { for k, v in fabric_workspace.workspaces : k => v.display_name }

#   display_name     = "${each.value}-contributor"
#   mail_nickname    = "${each.value}-contributor"
#   security_enabled = true
# }

# resource "azuread_group" "member_groups" {
#   for_each = { for k, v in fabric_workspace.workspaces : k => v.display_name }

#   display_name     = "${each.value}-member"
#   mail_nickname    = "${each.value}-member"
#   security_enabled = true
# }

# resource "azuread_group" "viewer_groups" {
#   for_each = { for k, v in fabric_workspace.workspaces : k => v.display_name }

#   display_name     = "${each.value}-viewer"
#   mail_nickname    = "${each.value}-viewer"
#   security_enabled = true
# }

# resource "fabric_workspace_role_assignment" "admin_role_assignments" {
#   for_each = { for k, v in fabric_workspace.workspaces : k => v }

#   workspace_id   = each.value.id
#   principal_id   = azuread_group.admin_groups[each.key].id
#   principal_type = "Group"
#   role           = "Admin"
# }

# resource "fabric_workspace_role_assignment" "contributor_role_assignments" {
#   for_each = { for k, v in fabric_workspace.workspaces : k => v }

#   workspace_id   = each.value.id
#   principal_id   = azuread_group.contributor_groups[each.key].id
#   principal_type = "Group"
#   role           = "Contributor"
# }

# resource "fabric_workspace_role_assignment" "member_role_assignments" {
#   for_each = { for k, v in fabric_workspace.workspaces : k => v }

#   workspace_id   = each.value.id
#   principal_id   = azuread_group.member_groups[each.key].id
#   principal_type = "Group"
#   role           = "Member"
# }

# resource "fabric_workspace_role_assignment" "viewer_role_assignments" {
#   for_each = { for k, v in fabric_workspace.workspaces : k => v }

#   workspace_id   = each.value.id
#   principal_id   = azuread_group.viewer_groups[each.key].id
#   principal_type = "Group"
#   role           = "Viewer"
# }

# Add resources for VNet, Private Link, etc., if needed

resource "azuredevops_project" "projects" {
  for_each = { for k, v in fabric_workspace.workspaces : k => v.display_name }

  name               = "Fabric-${each.key}"
  description        = "Fabric project for ${each.value}"
  version_control    = "Git"
  work_item_template = "Agile"
}

resource "azuredevops_git_repository" "repositories" {
  for_each = { for k, v in fabric_workspace.workspaces : k => v.display_name }

  project_id     = azuredevops_project.projects[each.key].id
  name           = "fabric-workspace-${each.key}"
  default_branch = "refs/heads/main"
  initialization {
    init_type = "Clean"
  }
}

resource "fabric_workspace_git" "git_integration" {
  for_each = { for k, v in fabric_workspace.workspaces : k => v }

  workspace_id            = each.value.id
  initialization_strategy = "PreferWorkspace"
  git_provider_details = {
    git_provider_type = "AzureDevOps"
    organization_name = "dm-ansone-ado"
    project_name      = "Fabric-${each.key}" # Dynamic project name
    repository_name   = "fabric-workspace-${each.key}"
    branch_name       = "main"
    directory_name    = "/"
  }
  depends_on = [fabric_workspace.workspaces, azuredevops_project.projects, azuredevops_git_repository.repositories]
}
