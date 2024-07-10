########################################################################################################################
# Local Values
########################################################################################################################
locals {
  # Returns 'true' if the word 'any' exists in the IP rules list.
  is_any_acl_present = try(
    contains(var.storage_account_network_acls.ip_rules, "any"),
    false
  )

  /* storage_account_network_acls
  Description: Returns a specific object that sets the Firewall of the storage account to a disabled state if no custom
  Firewall rules are defined or if the word 'any' exists in the Firewall IP rules.

  Example Outputs:
  [
    {
      bypass = ["AzureServices],
      default_action = "Allow",
      ip_rules = [],
      virtual_network_subnet_ids = []
    }
  ]
  */
  storage_account_network_acls = [
    local.is_any_acl_present || var.storage_account_network_acls == null ? {
      bypass                     = ["AzureServices"],
      default_action             = "Allow",
      ip_rules                   = [],
      virtual_network_subnet_ids = []
    } : var.storage_account_network_acls
  ]


}

########################################################################################################################
# Azure Storage Account
########################################################################################################################
resource "azurerm_storage_account" "this" {
  name                            = var.storage_account_name
  resource_group_name             = var.resource_group_name
  location                        = var.region
  account_kind                    = var.storage_account_kind
  access_tier                     = var.storage_account_access_tier
  account_tier                    = var.storage_account_tier
  account_replication_type        = var.storage_account_replication_type
  enable_https_traffic_only       = true
  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = true
  min_tls_version                 = var.storage_account_min_tls_version
  is_hns_enabled                  = var.storage_account_hns_enabled


  blob_properties {
    delete_retention_policy {
      days = var.blob_soft_delete_retention_days
    }
  }
  dynamic "network_rules" {
    for_each = local.storage_account_network_acls
    iterator = acl
    content {
      bypass                     = acl.value.bypass
      default_action             = acl.value.default_action
      ip_rules                   = acl.value.ip_rules
      virtual_network_subnet_ids = acl.value.virtual_network_subnet_ids
    }
  }


}

########################################################################################################################
# Azure Storage Data Lake
########################################################################################################################
# resource "azurerm_storage_data_lake_gen2_filesystem" "this" {
#   for_each           = var.data_lake_containers
#   storage_account_id = azurerm_storage_account.this.id
#   name               = each.key
# }

# # ------------------------------------------------------------------
# # azurerm monitoring diagnostics  - Default is "false" 
# # ------------------------------------------------------------------
# resource "azurerm_monitor_diagnostic_setting" "law" {
#   name                       = var.datalake-diag-name
#   target_resource_id         = azurerm_storage_account.this.id
#   log_analytics_workspace_id = var.log_analytics_workspace_id

#   dynamic "metric" {
#     for_each = toset(["Capacity", "Transaction"])
#     content {
#       category = metric.value
#       enabled  = true
#     }
#   }
# }
