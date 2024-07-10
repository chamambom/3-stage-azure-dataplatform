resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.virtual_network_address_space
}

resource "azurerm_subnet" "subnet" {
  for_each             = var.subnets
  name                 = each.value.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = var.resource_group_name
  address_prefixes     = each.value.address_prefixes

  dynamic "delegation" {
    for_each = [for d in each.value.delegations : d if d.name == "vnet_access_links"]
    content {
      name = "delegation-vnetAccessLinks"
      service_delegation {
        name    = "Microsoft.PowerPlatform/vnetaccesslinks"
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    }
  }

  dynamic "delegation" {
    for_each = [for d in each.value.delegations : d if d.name == "mysql"]
    content {
      name = "delegation-database"
      service_delegation {
        name    = "Microsoft.DBforMySQL/flexibleServers"
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    }
  }
}

