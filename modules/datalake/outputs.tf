########################################################################################################################
# OUTPUTS
########################################################################################################################
output "storage_account_id" {
  value       = azurerm_storage_account.this.id
  description = "The ID of the Azure Storage Account."
}

output "storage_account_name" {
  value       = azurerm_storage_account.this.name
  description = "The name of the Azure Storage Account."
}

output "storage_account_access_tier" {
  value       = azurerm_storage_account.this.access_tier
  description = "The storage account access tier."
}

output "storage_account_kind" {
  value       = azurerm_storage_account.this.account_kind
  description = "The storage account kind."
}

output "storage_account_account_tier" {
  value       = azurerm_storage_account.this.account_tier
  description = "The storage account tire."
}

output "storage_account_replication_type" {
  value       = azurerm_storage_account.this.account_replication_type
  description = "The storage account replication type."
}

# output "data_lake_containers" {
#   value       = try(azurerm_storage_data_lake_gen2_filesystem.this, {})
#   description = "A map of Azure Data Lake Gen 2 filesystem containers."
# }
