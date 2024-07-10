terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = "~>3.0"
      configuration_aliases = [azurerm]
    }
  }
}


resource "azurerm_resource_group" "rg" {
  # provider = azurerm.connectivity
  count    = var.create_resource ? 1 : 0
  name     = "rg-connectivity-dnszone-01"
  location = "australiaeast"

  tags = {
    function       = "DNS resolution"
    environment    = "Connectivity"
    createdby      = "Datacom"
    costcentre     = "T&S"
    classification = "Restricted"
    owner          = "Manager Data and Analytics"
    repository     = "ADO"
  }


}

data "azurerm_resource_group" "rg_lookup" {
  count = var.create_resource ? 0 : 1
  name  = "rg-connectivity-dnszone-01"
}


resource "azurerm_private_dns_zone" "this" {
  count               = var.create_resource ? length(var.dns_zone_names) : 0
  name                = var.dns_zone_names[count.index]
  resource_group_name = azurerm_resource_group.rg[0].name
}

data "azurerm_private_dns_zone" "lookup" {
  count               = var.create_resource ? 0 : length(var.dns_zone_names)
  name                = var.dns_zone_names[count.index]
  resource_group_name = data.azurerm_resource_group.rg_lookup[0].name
}


# locals {
#   vnet_dns_zone_map = flatten([
#     for dns_zone_name in var.dns_zone_names : [
#       for vnet_key, vnet_value in var.vnet_map : {
#         dns_zone_name = dns_zone_name
#         vnet_id       = vnet_value
#         key           = "${dns_zone_name}-${vnet_key}"
#       }
#     ]
#   ])
# }
# resource "azurerm_private_dns_zone_virtual_network_link" "this" {

#   for_each = {
#     for item in local.vnet_dns_zone_map :
#     item.key => item
#   }

#   name                  = "vnet-link-${each.key}"
#   private_dns_zone_name = each.value.dns_zone_name
#   resource_group_name   = azurerm_resource_group.rg[0].name
#   virtual_network_id    = each.value.vnet_id

#   depends_on = [azurerm_private_dns_zone.this, azurerm_resource_group.rg]
# }


locals {
  # Create a map to easily access DNS zone names and their resources
  dns_zone_map = {
    for i, dns_zone_name in var.dns_zone_names :
    dns_zone_name => var.create_resource ? azurerm_private_dns_zone.this[i].name : data.azurerm_private_dns_zone.lookup[i].name
  }

  # Generate a flattened list of vnet_dns_zone_map
  vnet_dns_zone_map = flatten([
    for dns_zone_name in var.dns_zone_names : [
      for vnet_key, vnet_value in var.vnet_map : {
        dns_zone_name = dns_zone_name
        vnet_id       = vnet_value
        key           = "${dns_zone_name}-${vnet_key}"
      }
    ]
  ])
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = {
    for item in local.vnet_dns_zone_map :
    item.key => item
  }

  name = "vnet-link-${each.key}"

  private_dns_zone_name = local.dns_zone_map[each.value.dns_zone_name]
  resource_group_name   = var.create_resource ? azurerm_resource_group.rg[0].name : data.azurerm_resource_group.rg_lookup[0].name

  virtual_network_id = each.value.vnet_id

  depends_on = [azurerm_private_dns_zone.this, azurerm_resource_group.rg]
}
