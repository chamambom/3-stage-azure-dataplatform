locals {
  endpoint = {
    for target, values in var.managed_private_endpoint : "${target.name}-${var.env}" => values
  }
}

resource "azurerm_data_factory_managed_private_endpoint" "main" {
  for_each = local.endpoint

  name               = each.key
  data_factory_id    = azurerm_data_factory.main.id
  target_resource_id = each.value.target_resource_id
  subresource_name   = each.value.subresource_name

  # lifecycle {
  #   ignore_changes = all
  # }

}
