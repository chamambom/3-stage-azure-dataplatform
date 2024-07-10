# -------------------------------------------------------------------
# Create Azure Data Factory
# -------------------------------------------------------------------
data "azurerm_client_config" "current" {}

resource "azurerm_data_factory" "main" {
  name                             = var.name
  location                         = var.rg-location
  resource_group_name              = var.rg-name
  managed_virtual_network_enabled  = var.managed_virtual_network_enabled
  public_network_enabled           = var.public_network_enabled
  customer_managed_key_id          = var.customer_managed_key_id
  customer_managed_key_identity_id = var.customer_managed_key_identity_id


  dynamic "vsts_configuration" {
    for_each = var.ado_git_configuration != null ? [var.ado_git_configuration] : []
    content {
      account_name       = vsts_configuration.value.account_name
      project_name       = vsts_configuration.value.project_name
      repository_name    = vsts_configuration.value.repository_name
      branch_name        = vsts_configuration.value.collaboration_branch
      root_folder        = vsts_configuration.value.root_folder
      tenant_id          = data.azurerm_client_config.current.tenant_id
      publishing_enabled = true
    }
  }

  dynamic "global_parameter" {
    for_each = var.global_parameters
    content {
      name  = global_parameter.key
      type  = global_parameter.value.type
      value = global_parameter.value.value
    }
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      global_parameter,
      # vsts_configuration
    ]
  }
}

# -------------------------------------------------------------------
# Optional Azure Integration Runtime
# -------------------------------------------------------------------
resource "azurerm_data_factory_integration_runtime_azure" "main" {
  for_each = var.azure_integration_runtime

  name                    = each.key
  data_factory_id         = azurerm_data_factory.main.id
  location                = var.rg-location
  description             = each.value.description
  compute_type            = each.value.compute_type
  core_count              = each.value.core_count
  time_to_live_min        = each.value.time_to_live_min
  cleanup_enabled         = each.value.cleanup_enabled
  virtual_network_enabled = each.value.virtual_network_enabled
}


# ------------------------------------------------------------------
# azurerm monitoring diagnostics  - Default is "false" 
# ------------------------------------------------------------------
# resource "azurerm_monitor_diagnostic_setting" "law" {
#   name                       = var.adf_diag_name
#   target_resource_id         = azurerm_data_factory.main.id
#   log_analytics_workspace_id = var.log_analytics_workspace_id

#   enabled_log {
#     category_group = "allLogs"
#   }

#   metric {
#     category = "AllMetrics"
#     enabled  = true
#   }
# }


