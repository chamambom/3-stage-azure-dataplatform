terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
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
  skip_provider_registration = true #
  features {}

}

provider "azurerm" {
  alias                      = "prod"
  subscription_id            = var.Production
  skip_provider_registration = true #
  features {}
}

provider "azurerm" {
  alias                      = "nonprod"
  subscription_id            = var.NonProduction
  skip_provider_registration = true #
  features {}
}

provider "azurerm" {
  alias                      = "mgmt"
  subscription_id            = var.Management
  skip_provider_registration = true #
  features {}
}

provider "azurerm" {
  alias                      = "connectivity"
  subscription_id            = var.Connectivity
  skip_provider_registration = true #
  features {}

}
