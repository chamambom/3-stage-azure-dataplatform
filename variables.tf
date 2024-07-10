# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Subscription variables
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
variable "Management" {
  description = "Management Subscription"
  type        = string
  default     = "w"
}
variable "Connectivity" {
  description = "Connectivity Subscription"
  type        = string
  default     = "x"
}
variable "NonProduction" {
  description = "NonProduction Subscription"
  type        = string
  default     = "y"
}
variable "Production" {
  description = "Production Subscription"
  type        = string
  default     = "z"
}

# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Networking - vnet, subnets , route tables and resource Group variables
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

variable "rg-name" {
  description = "The Name of the Resource Group"
  type        = string
}
variable "rg-location" {
  description = "The Azure Region where the Resource Group should exist"
  type        = string
}
variable "vnet-name" {
  type = string
}
variable "snet-01-name" {
  type = string
}
variable "snet-02-name" {
  type = string
}
variable "snet-03-name" {
  type = string
}
variable "snet-01-address-prefixes" {
  type = list(string)
}
variable "snet-02-address-prefixes" {
  type = list(string)
}
variable "rt-name" {
  type = string
}
variable "vnet-id" {
  type = string
}
variable "hubvnet-id" {
  type = string
}
variable "snet-03-address-prefixes" {
  type = list(string)
}
variable "vnet-address-prefixes" {
  type = list(string)
}
variable "datalake-endpoint-id" {
  type = string
}
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Datalake variables
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

variable "data-lake-storage-name" {
  type = string
}
variable "datalake-diag-name" {
  type = string
}
variable "storage_account_replication_type" {
  type = string
}
variable "blob_soft_delete_retention_days" {
  type = string
}
variable "container_soft_delete_retention_days" {
  type = string
}
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Azure Datafactory variables
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

variable "adf-name" {
  type = string
}

variable "ado_git_configuration" {
  description = "Azure DevOps Git configuration for ADF"
  type = object({
    account_name         = string
    project_name         = string
    repository_name      = string
    collaboration_branch = string
    root_folder          = string
    # tenant_id            = string - this variable was abstracted from the module implementation 
  })
  nullable = true
  default  = null
}


# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Private DNS Zones variables
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

variable "dns_zone_names" {
  type    = list(string)
  default = ["te-wheke.int", "privatelink.blob.core.windows.net", "privatelink.database.windows.net", "privatelink.datafactory.azure.net", "privatelink.adf.azure.com", "privatelink.azurewebsites.net", "privatelink.vaultcore.azure.net"]
}

variable "create_resource" {
  description = "Set to true to create the DNS zone and links, false to skip."
  type        = bool
  default     = false # You can set it to false to skip resource creation by default
}

# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Log diagnostics  variables
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
variable "log-analytics-wspace-name" {
  type = string
}
variable "retention_in_days" {
  type = string
}
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Azure MsSql Server and DB variables
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
variable "sqlserver-name" {
  type = string
}
variable "sqldb" {
  type = string
}
variable "ad-admin-login-name" {
  type = string
}
variable "adf_diag_name" {
  type = string
}

variable "sqldb-sku-name" {
  type = string
}
variable "sqldb-max_size_gb" {
  type = string
}
variable "sqldb-zone-redundancy" {
  type = bool
}
variable "sqldb-collation" {
  type = string
}
variable "sqldb-geo_backup_enabled" {
  type = bool
}
variable "azuread_administrator_login_username" {
  type = string
}

variable "object_id" {
  type = string
}

# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# private endpoints variables
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

variable "sql-server-private-endpoint" {
  type = string
}
variable "sql_server_private_ip_address" {
  type = string
}
variable "sql_server_member_name" {
  type = string
}

variable "sql_server_subresource_name" {
  type = string
}
# -------------------

variable "datalake-private-endpoint" {
  type = string
}
variable "datalake_private_ip_address" {
  type = string
}

variable "datalake_member_name" {
  type = string
}

variable "datalake_subresource_name" {
  type = string
}

# ---------------------
variable "datafactory-private-endpoint" {
  type = string
}
variable "datafactory_member_name" {
  type = string
}

variable "datafactory_private_ip_address" {
  type = string
}

variable "datafactory_subresource_name" {
  type = string
}

#---------------------

variable "datafactory-portal-private-endpoint" {
  type = string
}
variable "datafactory-portal_member_name" {
  type = string
}

variable "datafactory_portal_private_ip_address" {
  type = string
}

variable "datafactory-portal_subresource_name" {
  type = string
}

#---------------------

variable "webapp-private-endpoint" {
  type = string
}

variable "webapp_member_name" {
  type = string
}

variable "webapp_private_ip_address" {
  type = string
}

variable "webapp_subresource_name" {
  type = string
}
#----------------------

variable "keyvault-private-endpoint" {
  type = string
}
variable "keyvault_private_ip_address" {
  type = string
}

variable "keyvault_member_name" {
  type = string
}

variable "keyvault_subresource_name" {
  type = string
}

# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Keyvault variables
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

variable "kv-name" {
  type = string
}
variable "kv-sku" {
  type = string
}

# variable "kv-secrets" {
#   type = map(string)
# }


variable "keyvault_reader_group_names" {
  description = "List of group names for the roles."
  type        = list(string)
  default     = []
}

variable "keyvault_reader_service_principal_names" {
  description = "List of service principal names for the roles."
  type        = list(string)
  default     = []
}

# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# webapp variables
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

variable "app-service-name" {
  type = string
}
variable "app-service-plan-name" {
  type = string
}
variable "os-type" {
  type = string
}
variable "app-service-skuname" {
  type = string
}

# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Utility variables
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

variable "env" {
  description = "The environment to deploy to (e.g., dev, prod)."
  type        = string
}
