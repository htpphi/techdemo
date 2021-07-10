# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  # More information on the authentication methods supported by
  # the AzureRM Provider can be found here:
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs

  # subscription_id = "..."
  # client_id       = "..."
  # client_secret   = "..."
  # tenant_id       = "..."
}


resource "azurerm_resource_group" "goDemoChallengeApp" {
  name     = "goDemoResourceGroup"
  location = "australiasoutheast"
}

resource "azurerm_app_service_plan" "goDemoChallengeApp" {
  name                = "CloudAppServicePlan"
  location            = azurerm_resource_group.goDemoChallengeApp.location
  resource_group_name = azurerm_resource_group.goDemoChallengeApp.name
  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "goDemoChallengeApp" {
  name                = "ProductionAppService"
  location            = azurerm_resource_group.goDemoChallengeApp.location
  resource_group_name = azurerm_resource_group.goDemoChallengeApp.name
  app_service_plan_id = azurerm_app_service_plan.goDemoChallengeApp.id
}

resource "azurerm_app_service_slot" "goDemoChallengeApp" {
  name                = "ProductionAppServiceSlotOne"
  location            = azurerm_resource_group.goDemoChallengeApp.location
  resource_group_name = azurerm_resource_group.goDemoChallengeApp.name
  app_service_plan_id = azurerm_app_service_plan.goDemoChallengeApp.id
  app_service_name    = azurerm_app_service.goDemoChallengeApp.name
}