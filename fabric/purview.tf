resource "azurerm_resource_group" "purview_rg" {
  name     = "rg-purview-prod-${var.location_short}-001"
  location = var.location

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
