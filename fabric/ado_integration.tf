provider "azuredevops" {
  org_service_url       = "https://dev.azure.com/${var.azuredevops_org}"
  personal_access_token = var.azuredevops_pat
}

resource "azuredevops_project" "projects" {
  for_each = {
    for k, v in fabric_workspace.workspaces : k => v.display_name
    if k == "dev"
  }

  name               = "Fabric-${upper(substr(each.key, 0, 1))}${substr(each.key, 1, length(each.key) - 1)}"
  description        = "Fabric project for ${upper(substr(each.key, 0, 1))}${substr(each.key, 1, length(each.key) - 1)}"
  version_control    = "Git"
  work_item_template = "Agile"
}

resource "azuredevops_git_repository" "repositories" {
  for_each = {
    for k, v in fabric_workspace.workspaces : k => v.display_name
    if k == "dev"
  }

  project_id     = azuredevops_project.projects["dev"].id
  name           = "fabric-workspace-dev"
  default_branch = "refs/heads/main"
  initialization {
    init_type = "Clean"
  }
}

resource "fabric_workspace_git" "git_integration" {
  for_each = {
    for k, v in fabric_workspace.workspaces : k => v
    if k == "dev"
  }

  workspace_id            = each.value.id
  initialization_strategy = "PreferWorkspace"
  git_provider_details = {
    git_provider_type = "AzureDevOps"
    organization_name = var.azuredevops_org
    project_name      = "Fabric-${upper(substr(each.key, 0, 1))}${substr(each.key, 1, length(each.key) - 1)}"
    repository_name   = "fabric-workspace-dev"
    branch_name       = "main"
    directory_name    = "/"
  }
  depends_on = [fabric_workspace.workspaces, azuredevops_project.projects, azuredevops_git_repository.repositories]
}
