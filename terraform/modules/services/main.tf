# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
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

# Create a new Resource Group
resource "azurerm_resource_group" "demochallenge" {
    name                =  "demochallenge-RG"
    location            =  "australiasoutheast"
}

 #Create an App Service Plan with Linux
resource "azurerm_app_service_plan" "appserviceplan" {
  name                = "${azurerm_resource_group.demochallenge.name}-plan"
  location            = "${azurerm_resource_group.demochallenge.location}"
  resource_group_name = "${azurerm_resource_group.demochallenge.name}"

  # Define Linux as Host OS
  kind = "Linux"

  reserved            = true

  # Choose size
  sku {
    tier = "Standard"
    size = "S1"
  }


}
 #Create an Azure Web App for Containers in that App Service Plan
resource "azurerm_app_service" "dockerapp" {
  name                = "${azurerm_resource_group.demochallenge.name}-dockerapp"
  location            = "${azurerm_resource_group.demochallenge.location}"
  resource_group_name = "${azurerm_resource_group.demochallenge.name}"
  app_service_plan_id = "${azurerm_app_service_plan.appserviceplan.id}"

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false

    # Settings for private Container Registires  
    DOCKER_REGISTRY_SERVER_URL      = "https://index.docker.io"
    DOCKER_REGISTRY_SERVER_USERNAME = ""
    DOCKER_REGISTRY_SERVER_PASSWORD = ""
  }

  # Configure Docker Image to load on start
  site_config {
    linux_fx_version = "DOCKER|servian/techchallengeapp:latest"
    always_on        = "true"
  }

  identity {
    type = "SystemAssigned"
  }
}