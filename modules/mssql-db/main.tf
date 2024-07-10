resource "random_password" "main" {
  length      = var.random_password_length
  min_upper   = 4
  min_lower   = 2
  min_numeric = 4
  special     = false

  keepers = {
    administrator_login_password = var.sqlserver_name
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_mssql_server" "primary" {
  name                         = var.sqlserver_name
  resource_group_name          = var.rg-name
  location                     = var.rg-location
  version                      = "12.0"
  administrator_login          = var.admin_username == null ? "sqladmin" : var.admin_username
  administrator_login_password = var.admin_password == null ? random_password.main.result : var.admin_password

  azuread_administrator {
    login_username              = var.azuread_administrator_login_username
    object_id                   = var.object_id
    tenant_id                   = data.azurerm_client_config.current.tenant_id
    azuread_authentication_only = true
  }

  dynamic "identity" {
    for_each = var.identity == true ? [1] : [0]
    content {
      type = "SystemAssigned"
    }
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_mssql_firewall_rule" "example" {
  name             = "EnableAllowaccesstoAzureservices"
  server_id        = azurerm_mssql_server.primary.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

#--------------------------------------------------------------------
# SQL Database creation
#--------------------------------------------------------------------

resource "azurerm_mssql_database" "db" {
  name                        = var.database_name
  server_id                   = azurerm_mssql_server.primary.id
  sku_name                    = var.sqldb-sku-name
  max_size_gb                 = var.sqldb-max_size_gb
  zone_redundant              = var.sqldb-zone-redundancy
  collation                   = var.sqldb-collation
  geo_backup_enabled          = var.sqldb-geo_backup_enabled
  storage_account_type        = "Local"
  min_capacity                = 0.5
  auto_pause_delay_in_minutes = 60
}

# ------------------------------------------------------------------
# azurerm monitoring diagnostics  - Default is "false" 
# ------------------------------------------------------------------
# resource "azurerm_monitor_diagnostic_setting" "law" {
#   name                       = "diag-sqldb-tkrmdp-dev-ae-01"
#   target_resource_id         = azurerm_mssql_database.db.id
#   log_analytics_workspace_id = var.log_analytics_workspace_id

#   enabled_log {
#     category_group = "allLogs"
#   }

#   enabled_log {
#     category_group = "audit"
#   }

#   metric {
#     category = "AllMetrics"
#     enabled  = true
#   }
# }
