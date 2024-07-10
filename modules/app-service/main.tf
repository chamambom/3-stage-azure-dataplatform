resource "azurerm_service_plan" "main" {
  name                = var.service-plan-name
  resource_group_name = var.resource-group-name
  location            = var.location
  os_type             = var.os-type
  sku_name            = var.app-service-skuname



}


resource "azurerm_linux_web_app" "main" {
  name                          = var.app-service-name
  resource_group_name           = azurerm_service_plan.main.resource_group_name
  location                      = azurerm_service_plan.main.location
  service_plan_id               = azurerm_service_plan.main.id
  public_network_access_enabled = false
  https_only                    = true

  site_config {
    application_stack {
      node_version = "18-lts"

    }
  }
}
