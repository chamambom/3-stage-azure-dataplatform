# ------------------------------------------------------------------------------------------------------------------------------------------------------------
# Deploy Resource Groups
# ------------------------------------------------------------------------------------------------------------------------------------------------------------

module "dp-resourcegroup" {
  source      = "./modules/resourcegroups"
  rg-name     = var.rg-name
  rg-location = var.rg-location

  tags = var.tags
}

# -------------------------------------------------------------------------------------------------------------------------------------------------------------
# Deploy vnets and subnets 
# -------------------------------------------------------------------------------------------------------------------------------------------------------------

module "dp-vnet" {
  source = "./modules/vnet"

  virtual_network_name          = var.vnet-name
  resource_group_name           = module.dp-resourcegroup.rg-name
  location                      = module.dp-resourcegroup.rg-location
  virtual_network_address_space = var.vnet-address-prefixes

  subnets = {
    "snet-01" = {
      name             = var.snet-01-name
      address_prefixes = var.snet-01-address-prefixes
      delegations = [
        {
          name = ""
        }
      ]
    },
    "snet-02" = {
      name             = var.snet-02-name
      address_prefixes = var.snet-02-address-prefixes
      delegations = [
        {
          name = "vnet_access_links"
        },

      ]
    },

    "snet-03" = {
      name             = var.snet-03-name
      address_prefixes = var.snet-03-address-prefixes
      delegations = [
        {
          name = ""
        },

      ]
    },
  }

  depends_on = [module.dp-resourcegroup]

}

# -------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Deploy routetables and associate them with Subnets in the above virtual Networks
# -------------------------------------------------------------------------------------------------------------------------------------------------------------------
module "route_table_gateway_subnet" {
  source              = "./modules/routetables"
  name                = var.rt-name
  resource_group_name = var.rg-name
  location            = var.rg-location
  routes = [
    { name = "Fw-dg", address_prefix = "0.0.0.0/0", next_hop_type = "VirtualAppliance", next_hop_in_ip_address = "10.50.0.4" },
  ]
  disable_bgp_route_propagation = false
  subnet_ids                    = [module.dp-vnet.vnet_subnet_id[0], module.dp-vnet.vnet_subnet_id[1], module.dp-vnet.vnet_subnet_id[2]]

  depends_on = [module.dp-resourcegroup, module.dp-vnet]

}

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Deploy mssql-server & sql-db
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------

module "mssql-server" {
  source = "./modules/mssql-db"

  rg-name                              = var.rg-name
  rg-location                          = var.rg-location
  sqlserver_name                       = var.sqlserver-name
  database_name                        = var.sqldb
  sqldb-sku-name                       = var.sqldb-sku-name
  sqldb-collation                      = var.sqldb-collation
  sqldb-geo_backup_enabled             = var.sqldb-geo_backup_enabled
  sqldb-max_size_gb                    = var.sqldb-max_size_gb
  sqldb-zone-redundancy                = var.sqldb-zone-redundancy
  log_analytics_workspace_id           = data.azurerm_log_analytics_workspace.tpk-logging.id
  azuread_administrator_login_username = var.azuread_administrator_login_username
  object_id                            = var.object_id

  depends_on = [module.dp-resourcegroup, module.dp-vnet]
}


# ----------------------------------------------------------------------------------------------------------------------------------------------------------------
# Deploy datalake
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------

module "data-lake-gen2" {
  source = "./modules/datalake"

  region                           = var.rg-location
  resource_group_name              = var.rg-name
  storage_account_name             = var.data-lake-storage-name
  storage_account_replication_type = var.storage_account_replication_type
  # data_lake_containers             = ["general", "sensitive", "restricted", "teammanagedworkspaces"]
  blob_soft_delete_retention_days = var.blob_soft_delete_retention_days
  datalake-diag-name              = var.datalake-diag-name

  # storage_account_network_acls = {
  #   bypass                     = ["AzureServices"]
  #   default_action             = "Allow"
  #   ip_rules                   = ["any"]
  #   virtual_network_subnet_ids = []
  # }
  # log_analytics_workspace_id = module.log_analytics.workspace_id

  depends_on = [module.dp-resourcegroup, module.dp-vnet]

}

# --------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Deploy Datafactory
# --------------------------------------------------------------------------------------------------------------------------------------------------------------------
module "dp-adf" {
  source = "./modules/datafactory"

  name        = var.adf-name
  rg-name     = var.rg-name
  rg-location = var.rg-location
  # log_analytics_workspace_id = module.log_analytics.workspace_id
  adf_diag_name         = var.adf_diag_name
  ado_git_configuration = var.ado_git_configuration
  env                   = var.env

  # Set of Objects with parameters to create Managed endpoints in Integration Runtime Managed network.
  managed_private_endpoint = [{
    name               = "datalake"
    target_resource_id = module.data-lake-gen2.storage_account_id
    subresource_name   = "blob"
    },
    {
      name               = "sqlserver"
      target_resource_id = module.mssql-server.sql_server_id
      subresource_name   = "sqlServer"
    },
    {
      name               = "kvvault"
      target_resource_id = module.key-vault.key_vault_id
      subresource_name   = "vault"
  }, ]

  depends_on = [module.dp-resourcegroup, module.dp-vnet]

}




# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Deploy private Endpoints & attach the endpoints to a private DNS
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
module "dp-sql-server-private-endpoint" {
  source = "./modules/private-endpoint"

  pe_resource_group_name = var.rg-name
  private_endpoint_name  = var.sql-server-private-endpoint
  subresource_names      = ["sqlServer"]
  #subresource_names = var.subresource_names
  endpoint_resource_id = module.mssql-server.primary_sql_server_id
  #endpoint_resource_id = var.endpoint_resource_id
  pe_subnet_id       = module.dp-vnet.vnet_subnet_id[0]
  location           = var.rg-location
  private_ip_address = var.sql_server_private_ip_address
  member_name        = var.sql_server_member_name
  subresource_name   = var.sql_server_subresource_name


  dns = {
    zone_ids  = [module.dns.dns_zone_ids[2]]
    zone_name = var.dns_zone_names[2]
  }

  depends_on = [module.dp-resourcegroup, module.dp-vnet]
}

module "dp-datalake-private-endpoint" {
  source = "./modules/private-endpoint"

  pe_resource_group_name = var.rg-name
  private_endpoint_name  = var.datalake-private-endpoint
  subresource_names      = ["blob"]
  # endpoint_resource_id   = module.data-lake-gen2.storage_account_id # have to manually use the resource ID to address the race condition
  endpoint_resource_id = var.datalake-endpoint-id
  pe_subnet_id         = module.dp-vnet.vnet_subnet_id[0]
  location             = var.rg-location
  private_ip_address   = var.datalake_private_ip_address
  member_name          = var.datalake_member_name
  subresource_name     = var.datalake_subresource_name


  dns = {
    zone_ids  = [module.dns.dns_zone_ids[1]]
    zone_name = var.dns_zone_names[1]
  }

  depends_on = [module.dp-resourcegroup, module.dp-vnet]
}


module "dp-datafactory-private-endpoint" {
  source = "./modules/private-endpoint"

  pe_resource_group_name = var.rg-name
  private_endpoint_name  = var.datafactory-private-endpoint
  subresource_names      = ["dataFactory"]
  endpoint_resource_id   = module.tpk-adf.data_factory_id
  pe_subnet_id           = module.dp-vnet.vnet_subnet_id[0]
  location               = var.rg-location
  private_ip_address     = var.datafactory_private_ip_address
  member_name            = var.datafactory_member_name
  subresource_name       = var.datafactory_subresource_name


  dns = {
    zone_ids  = [module.dns.dns_zone_ids[3]]
    zone_name = var.dns_zone_names[3]
  }
  depends_on = [module.dp-resourcegroup, module.dp-vnet]
}


module "dp-datafactory-portal-private-endpoint" {
  source = "./modules/private-endpoint"

  pe_resource_group_name = var.rg-name
  private_endpoint_name  = var.datafactory-portal-private-endpoint
  subresource_names      = ["portal"]
  endpoint_resource_id   = module.tpk-adf.data_factory_id
  pe_subnet_id           = module.dp-vnet.vnet_subnet_id[0]
  location               = var.rg-location
  private_ip_address     = var.datafactory_portal_private_ip_address
  member_name            = var.datafactory-portal_member_name
  subresource_name       = var.datafactory-portal_subresource_name


  dns = {
    zone_ids  = [module.dns.dns_zone_ids[4]]
    zone_name = var.dns_zone_names[4]
  }

  depends_on = [module.dp-resourcegroup, module.dp-vnet]
}


module "dp-webapp-private-endpoint" {
  source = "./modules/private-endpoint"

  pe_resource_group_name = var.rg-name
  private_endpoint_name  = var.webapp-private-endpoint
  subresource_names      = ["sites"]
  endpoint_resource_id   = module.appservices.app_service_id
  pe_subnet_id           = module.dp-vnet.vnet_subnet_id[2]
  location               = var.rg-location
  private_ip_address     = var.webapp_private_ip_address
  member_name            = var.webapp_member_name
  subresource_name       = var.webapp_subresource_name


  dns = {
    zone_ids  = [module.dns.dns_zone_ids[5]]
    zone_name = var.dns_zone_names[5]
  }

  depends_on = [module.dp-resourcegroup, module.dp-vnet]
}

module "dp-keyvault-private-endpoint" {
  source = "./modules/private-endpoint"

  pe_resource_group_name = var.rg-name
  private_endpoint_name  = var.keyvault-private-endpoint
  subresource_names      = ["vault"]
  endpoint_resource_id   = module.key-vault.key_vault_id
  pe_subnet_id           = module.dp-vnet.vnet_subnet_id[0]
  location               = var.rg-location
  private_ip_address     = var.keyvault_private_ip_address
  member_name            = var.keyvault_member_name
  subresource_name       = var.keyvault_subresource_name


  dns = {
    zone_ids  = [module.dns.dns_zone_ids[6]]
    zone_name = var.dns_zone_names[6]
  }

  depends_on = [module.dp-resourcegroup, module.dp-vnet]
}

# ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Deploy Log Analytics Workspace
# ---------------------------------------------------------------------------------------------------------------------------------------------------------------------

module "dp-log_analytics" {
  source                        = "./modules/log-analytics"
  workspace_name                = var.log-analytics-wspace-name
  resource_group_name           = var.rg-name
  location                      = var.rg-location
  sku                           = "PerGB2018"
  local_authentication_disabled = true
  retention_in_days             = var.retention_in_days

  depends_on = [module.mssql-server]
}

# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Deploy key vault
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

module "dp-key-vault" {
  source = "./modules/keyvault"

  key_vault_name             = var.kv-name
  key_vault_sku_pricing_tier = var.kv-sku
  location                   = var.rg-location
  resource_group_name        = var.rg-name

  # Once `Purge Protection` has been Enabled it's not possible to Disable it
  # Deleting the Key Vault with `Purge Protection` enabled will schedule the Key Vault to be deleted
  # The default retention period is 90 days, possible values are from 7 to 90 days
  # use `soft_delete_retention_days` to set the retention period
  enable_purge_protection = false
  # soft_delete_retention_days = 7


  # Create a required Secrets as per your need.
  # When you Add `usernames` with empty password this module creates a strong random password
  # use .tfvars file to manage the secrets as variables to avoid security issues.

  keyvault_reader_group_names             = var.keyvault_reader_group_names
  keyvault_reader_service_principal_names = var.keyvault_reader_service_principal_names

  # secrets = var.kv-secrets


  # (Optional) To enable Azure Monitoring for Azure Application Gateway 
  # (Optional) Specify `storage_account_id` to save monitoring logs to storage. 
  #log_analytics_workspace_id = data.azurerm_log_analytics_workspace.tpk-logging.workspace_id
  #storage_account_id         = var.storage_account_id

  network_acls = {
    bypass         = "AzureServices"
    default_action = "Allow"
    # One or more IP Addresses, or CIDR Blocks to access this Key Vault.
    ip_rules = [] # This is my Datacom IP that I was using to test this capability.

    # One or more Subnet ID's to access this Key Vault.
    virtual_network_subnet_ids = []
  }

  depends_on = [module.dp-resourcegroup]
}


# ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Deploy app services
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------

module "dp-appservices" {
  source              = "./modules/app-service"
  app-service-name    = var.app-service-name
  service-plan-name   = var.app-service-plan-name
  os-type             = var.os-type
  app-service-skuname = var.app-service-skuname
  resource-group-name = var.rg-name
  location            = var.rg-location

  depends_on = [module.dp-resourcegroup, module.dp-vnet]
}

# ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
#
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
