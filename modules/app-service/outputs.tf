output "service_plan_id" {
  description = "The resource ID of the App Service Plan component"
  value       = azurerm_service_plan.main.id
}

output "service_plan_name" {
  description = "The resource ID of the App Service Plan component"
  value       = azurerm_service_plan.main.name
}

output "app_service_id" {
  description = "The resource ID of the App Service component"
  value       = azurerm_linux_web_app.main.id
}

output "app_service_name" {
  description = "The resource ID of the App Service component"
  value       = azurerm_linux_web_app.main.name
}
