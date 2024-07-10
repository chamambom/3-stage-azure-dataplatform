data "azurerm_client_config" "current" {}

locals {
  computed_tags = merge(
    var.tags,
    {
      CreatedOn = format("%s", timestamp())
    }
  )
}


resource "azurerm_resource_group" "rg" {
  name     = var.rg-name
  location = var.rg-location
  tags     = local.computed_tags
}


resource "azurerm_role_assignment" "datafactoryGitIntergration" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Data Factory Contributor"
  principal_id         = data.azurerm_client_config.current.object_id

  depends_on = [
    azurerm_resource_group.rg
  ]
}
