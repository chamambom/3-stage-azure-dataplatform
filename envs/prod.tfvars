# ------------------------------------------------------------------------------------------------------------------------------------------------------------
# Deploy Resource Groups
# ------------------------------------------------------------------------------------------------------------------------------------------------------------

rg-name     = "rg-prod-ae-01"
rg-location = "australiaeast"

tags = {
  function       = "DP Production"
  environment    = "Prod"
  createdby      = "Martin Chamambo"
  costcentre     = "DA"
  classification = "Restricted"
  owner          = "Data and Analytics"
  repository     = "ADO"
}
# -------------------------------------------------------------------------------------------------------------------------------------------------------------
# Deploy vnets and subnets 
# -------------------------------------------------------------------------------------------------------------------------------------------------------------
vnet-name                = "vnet-prod-ae-01"
snet-01-name             = "snet-prod-ae-01"
snet-02-name             = "snet-proddatgw-ae-01"
snet-03-name             = "snet-prodwebapp-ae-01"
vnet-address-prefixes    = ["10.50.11.128/25"]
snet-01-address-prefixes = ["10.50.11.128/26"]
snet-02-address-prefixes = ["10.50.11.192/28"]
snet-03-address-prefixes = ["10.50.11.208/28"]

# -------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Deploy routetables and associate them with Subnets in the above virtual Networks
# -------------------------------------------------------------------------------------------------------------------------------------------------------------------

vnet-id              = "/subscriptions/x/resourceGroups/rg-prod-ae-01/providers/Microsoft.Network/virtualNetworks/vnet-prod-ae-01"
hubvnet-id           = "/subscriptions/x/resourceGroups/rg-connectivity-hub-01/providers/Microsoft.Network/virtualNetworks/vnet-connectivity-hub-prod-01"
datalake-endpoint-id = "/subscriptions/x/resourceGroups/rg-prod-ae-01/providers/Microsoft.Storage/storageAccounts/stdpdevae01"
rt-name              = "rt-prod-ae-01"

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Deploy mssql-server & sql-db
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
sqlserver-name                       = "sql-prod-ae-01"
sqldb                                = "sqldb-prod-ae-01"
ad-admin-login-name                  = "Admin-sql-prod"
sqldb-sku-name                       = "GP_S_Gen5_1"
sqldb-max_size_gb                    = "32"
sqldb-zone-redundancy                = false
sqldb-collation                      = "SQL_Latin1_General_CP1_CI_AS"
sqldb-geo_backup_enabled             = true
azuread_administrator_login_username = "Admin-sql-prod"
object_id                            = "x"


# ----------------------------------------------------------------------------------------------------------------------------------------------------------------
# Deploy datalake
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------

data-lake-storage-name               = "stdpdevae01"
datalake-diag-name                   = "diag-stdpdevae01"
blob_soft_delete_retention_days      = "40"
container_soft_delete_retention_days = "40"
storage_account_replication_type     = "ZRS"

# --------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Deploy Datafactory
# --------------------------------------------------------------------------------------------------------------------------------------------------------------------

adf-name      = "adf-prod-ae-01"
adf_diag_name = "diag-adf-prod-ae-01"


# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Deploy private Endpoints & attach the endpoints to a private DNS
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
keyvault-private-endpoint   = "pe-kv-prod-ae-01"
keyvault_private_ip_address = "10.50.11.136"
keyvault_member_name        = "default"
keyvault_subresource_name   = "vault"

sql-server-private-endpoint   = "pe-sql-prod-ae-01"
sql_server_private_ip_address = "10.50.11.132"
sql_server_member_name        = "sqlServer"
sql_server_subresource_name   = "sqlServer"

datalake-private-endpoint   = "pe-st-prod-ae-01"
datalake_private_ip_address = "10.50.11.135"
datalake_member_name        = "blob"
datalake_subresource_name   = "blob"

webapp-private-endpoint   = "pe-app-prod-ae-01"
webapp_private_ip_address = "10.50.11.212"
webapp_member_name        = "sites"
webapp_subresource_name   = "sites"

datafactory-private-endpoint   = "pe-adfdf-prod-ae-01"
datafactory_private_ip_address = "10.50.11.133"
datafactory_member_name        = "dataFactory"
datafactory_subresource_name   = "dataFactory"

datafactory-portal-private-endpoint   = "pe-adfp-prod-ae-01"
datafactory_portal_private_ip_address = "10.50.11.134"
datafactory-portal_member_name        = "portal"
datafactory-portal_subresource_name   = "portal"

# ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Deploy Log Analytics Workspace
# ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
log-analytics-wspace-name = "log-datlake-prod-ae-01"
retention_in_days         = "30"
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Deploy key vault
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

kv-name = "kv-prod-ae-01"
kv-sku  = "standard"

## I only created reader AD Groups & reader  Service pricipals
#keyvault_reader_service_principal_names = ["Terraform"]
# keyvault_reader_group_names = [""]

# kv-secrets = {
#   "prod-datafactory-sample-secret" = ""
#   "prod-application-sample-secret" = ""
# }

# ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Deploy app services
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------

app-service-name      = "app-prod-ae-01"
app-service-plan-name = "asp-prod-ae-01"
os-type               = "Linux"
app-service-skuname   = "P2v3"

# ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Utility variables
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
env             = "prod"
create_resource = false
