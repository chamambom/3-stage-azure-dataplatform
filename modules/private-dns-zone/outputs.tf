# output "id" {
#   value       = try(azurerm_private_dns_zone.this[0].id, null)
#   description = "Private DNS Zone Id"
# }

# output "name" {
#   value       = try(azurerm_private_dns_zone.this[0].name, null)
#   description = "Private DNS Zone Name"
# }

# output "resource_group" {
#   value       = try(azurerm_private_dns_zone.this[0].resource_group_name, null)
#   description = "Private DNS Zone Resource Group"
# }

# output "vnet_link_name_to_id_map" {
#   value = {
#     for k, v in var.vnet_map :
#     azurerm_private_dns_zone_virtual_network_link.this[k].name => azurerm_private_dns_zone_virtual_network_link.this[k].id
#   }
#   description = "Map of Virtual Network Link names to it's ids"
# }



# output "dns_zone_names" {
#   value       = azurerm_private_dns_zone.this[*].name
#   description = "The names of the created private DNS zones."
# }

# output "dns_zone_ids" {
#   value       = azurerm_private_dns_zone.this[*].id
#   description = "The IDs of the created private DNS zones."
# }

output "dns_zone_names" {
  value       = var.create_resource ? [for dns in azurerm_private_dns_zone.this : dns.name] : [for dns in data.azurerm_private_dns_zone.lookup : dns.name]
  description = "The names of the created or looked up private DNS zones."
}

output "dns_zone_ids" {
  value       = var.create_resource ? [for dns in azurerm_private_dns_zone.this : dns.id] : [for dns in data.azurerm_private_dns_zone.lookup : dns.id]
  description = "The IDs of the created or looked up private DNS zones."
}
