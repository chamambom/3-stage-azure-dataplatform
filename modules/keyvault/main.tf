# Data sources to look up object IDs
data "azuread_group" "groups" {
  for_each     = toset(var.keyvault_reader_group_names)
  display_name = each.value
}

data "azuread_service_principal" "service_principals" {
  for_each     = toset(var.keyvault_reader_service_principal_names)
  display_name = each.value
}

data "azurerm_client_config" "current" {}

#-------------------------------------------------
# Keyvault Creation - Default is "true"
#-------------------------------------------------
resource "azurerm_key_vault" "main" {
  name                            = var.key_vault_name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = var.key_vault_sku_pricing_tier
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment
  soft_delete_retention_days      = var.soft_delete_retention_days
  enable_rbac_authorization       = var.enable_rbac_authorization
  purge_protection_enabled        = var.enable_purge_protection
  public_network_access_enabled   = false


  dynamic "network_acls" {
    for_each = var.network_acls != null ? [true] : []
    content {
      bypass                     = var.network_acls.bypass
      default_action             = var.network_acls.default_action
      ip_rules                   = var.network_acls.ip_rules
      virtual_network_subnet_ids = var.network_acls.virtual_network_subnet_ids
    }
  }

  dynamic "contact" {
    for_each = var.certificate_contacts
    content {
      email = contact.value.email
      name  = contact.value.name
      phone = contact.value.phone
    }
  }

  lifecycle {
    ignore_changes = [
      sku_name,
      tenant_id
    ]
  }
}


resource "azurerm_role_assignment" "key_vault_admin" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id

  depends_on = [
    azurerm_key_vault.main
  ]
}

# Time delay to avoid race condition (optional)
resource "time_sleep" "wait_10_seconds" {
  depends_on = [
    azurerm_role_assignment.key_vault_admin
  ]
  create_duration = "5s" # Wait for 10 seconds
}


resource "azurerm_role_assignment" "key_vault_reader_groups" {
  for_each             = data.azuread_group.groups
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Reader"
  principal_id         = each.value.object_id
}

resource "azurerm_role_assignment" "key_vault_service_principals" {
  for_each             = data.azuread_service_principal.service_principals
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Reader" # Change the role as necessary
  principal_id         = each.value.object_id

}

#-----------------------------------------------------------------------------------
# Keyvault Secret - Random password Creation if value is empty - Default is "false"
#-----------------------------------------------------------------------------------

# resource "random_password" "passwd" {
#   for_each    = { for k, v in var.secrets : k => v if v == "" }
#   length      = var.random_password_length
#   min_upper   = 4
#   min_lower   = 2
#   min_numeric = 4
#   min_special = 4

#   keepers = {
#     name = each.key
#   }
# }

# resource "azurerm_key_vault_secret" "keys" {
#   for_each     = var.secrets
#   name         = each.key
#   value        = each.value != "" ? each.value : random_password.passwd[each.key].result
#   key_vault_id = azurerm_key_vault.main.id

#   depends_on = [
#     azurerm_role_assignment.key_vault_admin,
#     time_sleep.wait_10_seconds # Ensure role assignment propagation
#   ]

#   lifecycle {
#     ignore_changes = [
#       value
#     ]
#   }
# }


# #---------------------------------------------------
# # azurerm monitoring diagnostics - KeyVault
# #---------------------------------------------------
# resource "azurerm_monitor_diagnostic_setting" "diag" {
#   count                      = var.log_analytics_workspace_id != null ? 1 : 0
#   name                       = lower(format("%s-diag", azurerm_key_vault.main.name))
#   target_resource_id         = azurerm_key_vault.main.id
#   log_analytics_workspace_id = var.log_analytics_workspace_id
#   storage_account_id         = var.storage_account_id != null ? var.storage_account_id : null

#   dynamic "log" {
#     for_each = var.kv_diag_logs
#     content {
#       category = log.value
#       enabled  = true

#       retention_policy {
#         enabled = false
#         days    = 0
#       }
#     }
#   }

#   metric {
#     category = "AllMetrics"
#     enabled  = true

#     retention_policy {
#       enabled = false
#     }
#   }
# }
