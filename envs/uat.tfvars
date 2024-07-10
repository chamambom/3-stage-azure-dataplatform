# ------------------------------------------------------------------------------------------------------------------------------------------------------------
# Deploy Resource Groups
# ------------------------------------------------------------------------------------------------------------------------------------------------------------

rg-name     = "rg-uat-ae-01"
rg-location = "australiaeast"

tags = {
  function       = "DP User Acceptance Testing"
  environment    = "Uat"
  createdby      = "Martin Chamambo"
  costcentre     = "DA"
  classification = "Restricted"
  owner          = "Data Analytics"
  repository     = "ADO"
}

# -------------------------------------------------------------------------------------------------------------------------------------------------------------
# Deploy vnets and subnets 
# -------------------------------------------------------------------------------------------------------------------------------------------------------------
vnet-name                = "vnet-uat-ae-01"
snet-01-name             = "snet-uat-ae-01"
snet-02-name             = "snet-uatdatgw-ae-01"
snet-03-name             = "snet-uatwebapp-ae-01"
vnet-address-prefixes    = ["10.50.11.0/25"]
snet-01-address-prefixes = ["10.50.11.0/26"]
snet-02-address-prefixes = ["10.50.11.64/28"]
snet-03-address-prefixes = ["10.50.11.80/28"]

# -------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Deploy routetables and associate them with Subnets in the above virtual Networks
# -------------------------------------------------------------------------------------------------------------------------------------------------------------------

vnet-id              = "/subscriptions/1f08ddec-51ca-4143-9e14-3fcd336fe2fd/resourceGroups/rg-uat-ae-01/providers/Microsoft.Network/virtualNetworks/vnet-uat-ae-01"
hubvnet-id           = "/subscriptions/14ce9ebd-ee6b-410f-ac4e-dab5810af069/resourceGroups/rg-connectivity-hub-01/providers/Microsoft.Network/virtualNetworks/vnet-connecitivty-hub-prod-01"
datalake-endpoint-id = "/subscriptions/1f08ddec-51ca-4143-9e14-3fcd336fe2fd/resourceGroups/rg-uat-ae-01/providers/Microsoft.Storage/storageAccounts/stdpuatae01"
rt-name              = "rt-uat-ae-01"

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Deploy mssql-server & sql-db
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
sqlserver-name                       = "sql-uat-ae-01"
sqldb                                = "sqldb-uat-ae-01"
ad-admin-login-name                  = "Admin-sql-uat"
sqldb-sku-name                       = "GP_S_Gen5_1"
sqldb-max_size_gb                    = "32"
sqldb-zone-redundancy                = false
sqldb-collation                      = "SQL_Latin1_General_CP1_CI_AS"
sqldb-geo_backup_enabled             = true
azuread_administrator_login_username = "Admin-sql-uat"
object_id                            = "8b76cfa8-4110-4627-9e45-0a424a1ba730"

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------
# Deploy datalake
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------

data-lake-storage-name               = "stdpuatae01"
datalake-diag-name                   = "diag-stdpuatae01"
blob_soft_delete_retention_days      = "40"
container_soft_delete_retention_days = "40"
storage_account_replication_type     = "LRS"


# --------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Deploy Datafactory
# --------------------------------------------------------------------------------------------------------------------------------------------------------------------

adf-name      = "adf-uat-ae-01"
adf_diag_name = "diag-adf-uat-ae-01"

# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Deploy private Endpoints & attach the endpoints to a private DNS
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
keyvault-private-endpoint   = "pe-kv-uat-ae-01"
keyvault_private_ip_address = "10.50.11.8"
keyvault_member_name        = "default"
keyvault_subresource_name   = "vault"

sql-server-private-endpoint   = "pe-sql-uat-ae-01"
sql_server_private_ip_address = "10.50.11.4"
sql_server_member_name        = "sqlServer"
sql_server_subresource_name   = "sqlServer"


datalake-private-endpoint   = "pe-st-uat-ae-01"
datalake_private_ip_address = "10.50.11.7"
datalake_member_name        = "blob"
datalake_subresource_name   = "blob"

webapp-private-endpoint   = "pe-app-uat-ae-01"
webapp_private_ip_address = "10.50.11.84"
webapp_member_name        = "sites"
webapp_subresource_name   = "sites"


datafactory-private-endpoint   = "pe-adfdf-uat-ae-01"
datafactory_private_ip_address = "10.50.11.5"
datafactory_member_name        = "dataFactory"
datafactory_subresource_name   = "dataFactory"

datafactory-portal-private-endpoint   = "pe-adfp-uat-ae-01"
datafactory_portal_private_ip_address = "10.50.11.6"
datafactory-portal_member_name        = "portal"
datafactory-portal_subresource_name   = "portal"
# ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Deploy Log Analytics Workspace
# ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
log-analytics-wspace-name = "log-datlake-uat-ae-01"
retention_in_days         = "30"
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Deploy key vault
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

kv-name = "kv-uat-ae-01"
kv-sku  = "standard"

## I only created reader AD Groups & reader  Service pricipals
# keyvault_reader_service_principal_names = ["Terraform"]
# keyvault_reader_group_names = [""]

# kv-secrets = {
#   "uat-datafactory-sample-secret" = ""
#   "uat-application-sample-secret" = ""
# }

# ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Deploy app services
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------

app-service-name      = "app-uat-ae-01"
app-service-plan-name = "asp-uat-ae-01"
os-type               = "Linux"
app-service-skuname   = "B3"

# ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Utility variables
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
env             = "uat"
create_resource = false
