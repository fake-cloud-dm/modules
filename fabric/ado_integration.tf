provider "azuredevops" {
  org_service_url       = "https://dev.azure.com/${var.azuredevops_org}"
  personal_access_token = var.azuredevops_pat
}

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
