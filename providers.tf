terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.24.0"
    }
  }
}

provider "random" {
  # Configuration options
}

provider "azuread" {
  # Configuration options
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  resource_provider_registrations = none #
  features {}

}

provider "azurerm" {
  alias                           = "prod"
  subscription_id                 = var.Production
  resource_provider_registrations = none #
  features {}
}

provider "azurerm" {
  alias                           = "nonprod"
  subscription_id                 = var.NonProduction
  resource_provider_registrations = none #
  features {}
}

provider "azurerm" {
  alias                           = "mgmt"
  subscription_id                 = var.Management
  resource_provider_registrations = none #
  features {}
}

provider "azurerm" {
  alias                           = "connectivity"
  subscription_id                 = var.Connectivity
  resource_provider_registrations = none #
  features {}

}
