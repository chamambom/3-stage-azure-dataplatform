# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Deploy log analytics 
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Reuse existing loganalytics workspace
data "azurerm_log_analytics_workspace" "main-logging" {
  provider            = azurerm.mgmt
  name                = "xyz"
  resource_group_name = "rg-"
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Deploy private DNS Zones
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
module "dns" {
  source = "./modules/private-dns-zone"

  depends_on = [module.dp-vnet]

  dns_zone_names  = var.dns_zone_names
  create_resource = var.create_resource
  vnet_map = tomap({
    # (data.azurerm_virtual_network.example.name) = data.azurerm_virtual_network.example.id
    # (module.dp-vnet.vnet_name) = module.dp-vnet.vnet_id  
    (module.dp-vnet.vnet_name) = var.vnet-id
  })

  providers = {
    azurerm = azurerm.connectivity
  }
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Deploy vnet peering
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------


data "azurerm_virtual_network" "hub-vnet" {
  provider            = azurerm.connectivity
  name                = "vnet-connectivity-hub-prod-01"
  resource_group_name = "rg-connectivity-hub-01"
}




# hub-to-data-vnet
module "hub-to-data-vnet" {
  source                       = "./modules/vnet-peering"
  virtual_network_peering_name = "connecitivty-hub-prod-01-vnet-to-dataplatform-${var.env}-vnet"
  resource_group_name          = data.azurerm_virtual_network.hub-vnet.resource_group_name
  virtual_network_name         = data.azurerm_virtual_network.hub-vnet.name
  remote_virtual_network_id    = module.dp-vnet.vnet_id
  # remote_virtual_network_id    = var.vnet-id
  allow_virtual_network_access = "true"
  allow_forwarded_traffic      = "true"
  allow_gateway_transit        = "true"
  use_remote_gateways          = "false"

  providers = {
    azurerm = azurerm.connectivity
  }

}

module "data-vnet-to-hub-nonprod" {
  count  = var.env != "prod" ? 1 : 0
  source = "./modules/vnet-peering"

  virtual_network_peering_name = "dataplatform-${var.env}-vnet-to-connecitivty-hub-prod-01-vnet"
  resource_group_name          = module.dp-resourcegroup.rg-name
  virtual_network_name         = module.dp-vnet.vnet_name
  remote_virtual_network_id    = data.azurerm_virtual_network.hub-vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true

  providers = {
    azurerm = azurerm.nonprod
  }
}

module "data-vnet-to-hub-prod" {
  count  = var.env == "prod" ? 1 : 0
  source = "./modules/vnet-peering"

  virtual_network_peering_name = "dataplatform-${var.env}-vnet-to-connecitivty-hub-prod-01-vnet"
  resource_group_name          = module.dp-resourcegroup.rg-name
  virtual_network_name         = module.dp-vnet.vnet_name
  remote_virtual_network_id    = data.azurerm_virtual_network.hub-vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true

  providers = {
    azurerm = azurerm.prod
  }
}


# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
#
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
