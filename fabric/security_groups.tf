# resource "azuread_group" "ans_engineer_fabric_admin" {
#   display_name     = "sg_ans_fabric_engineers_admin"
#   mail_nickname    = "sg_ans_fabric_engineers_admin"
#   security_enabled = true
# }

# resource "fabric_workspace_role_assignment" "admin_role_assignments" {
#   for_each = { for k, v in fabric_workspace.workspaces : k => v }

#   workspace_id   = each.value.id
#   principal_id   = azuread_group.ans_engineer_fabric_admin.id
#   principal_type = "Group"
#   role           = "Admin"
# }

# resource "azuread_group" "admin_groups" {
#   for_each = { for k, v in fabric_workspace.workspaces : k => v.display_name }

#   display_name     = "sg_fabric_workspace_${each.value}_admin"
#   mail_nickname    = "sg_fabric_workspace_${each.value}_admin"
#   security_enabled = true
# }

# resource "azuread_group" "contributor_groups" {
#   for_each = { for k, v in fabric_workspace.workspaces : k => v.display_name }

#   display_name     = "sg_fabric_workspace_${each.value}_contributor"
#   mail_nickname    = "sg_fabric_workspace_${each.value}_contributor"
#   security_enabled = true
# }

# resource "azuread_group" "member_groups" {
#   for_each = { for k, v in fabric_workspace.workspaces : k => v.display_name }

#   display_name     = "sg_fabric_workspace_${each.value}_member"
#   mail_nickname    = "sg_fabric_workspace_${each.value}_member"
#   security_enabled = true
# }

# resource "azuread_group" "viewer_groups" {
#   for_each = { for k, v in fabric_workspace.workspaces : k => v.display_name }

#   display_name     = "sg_fabric_workspace_${each.value}_viewer"
#   mail_nickname    = "sg_fabric_workspace_${each.value}_viewer"
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
