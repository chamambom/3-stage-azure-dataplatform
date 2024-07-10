resource "azurerm_log_analytics_workspace" "log_analytics_wname" {
  name                          = var.workspace_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  local_authentication_disabled = var.local_authentication_disabled
  sku                           = var.sku
  retention_in_days             = var.retention_in_days
}
