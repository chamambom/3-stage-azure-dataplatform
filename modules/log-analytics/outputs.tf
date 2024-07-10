output "workspace_id" {
  description = "The ID of this Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.log_analytics_wname.id
  sensitive   = true
}

output "workspace_customer_id" {
  description = "The workspace (customer) ID of this Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.log_analytics_wname.workspace_id
  sensitive   = true
}

output "primary_shared_key" {
  description = "The primary shared key of this Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.log_analytics_wname.primary_shared_key
  sensitive   = true
}

output "secondary_shared_key" {
  description = "The secondary shared key of this Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.log_analytics_wname.secondary_shared_key
  sensitive   = true
}
