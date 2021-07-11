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

locals {
 env_variables = {
   DOCKER_REGISTRY_SERVER_URL            = "https://arc01.azurecr.io"
   DOCKER_REGISTRY_SERVER_USERNAME       = "ACR01"
   DOCKER_REGISTRY_SERVER_PASSWORD       = "**************"
 }
}

# Create a new Resource Group
resource "azurerm_resource_group" "MYRG" {
    name                =  "MYRG"
    location            =  "australiasoutheast"
}

resource "azurerm_user_assigned_identity" "assigned_identity" {
  resource_group_name = azurerm_resource_group.MYRG.name
  location            = azurerm_resource_group.MYRG.location
  name = "User_ACR_pull"
}

resource "azurerm_app_service_plan" "my_service_plan" {
 name                = "my_service_plan"
 location            = "Australia SouthEast"
 resource_group_name = azurerm_resource_group.MYRG.name
 kind                = "Linux"
 reserved            = true

 sku {
   tier     = "Standard"
   size     = "S1"
   capacity = "5"
 }
}

resource "azurerm_app_service" "my_app_service_container" {
 name                    = "myappservicecontainer"
 location                = "Australia southeast"
 resource_group_name     = azurerm_resource_group.MYRG.name
 app_service_plan_id     = azurerm_app_service_plan.my_service_plan.id
 https_only              = true
 client_affinity_enabled = true
 site_config {
   scm_type  = "VSTSRM"
   always_on = "true"

   linux_fx_version  = "DOCKER|arc01.azurecr.io/myapp:latest" #define the images to usecfor you application

   health_check_path = "/health" # health check required in order that internal app service plan loadbalancer do not loadbalance on instance down
 }

 identity {
   type         = "SystemAssigned, UserAssigned"
   identity_ids = [azurerm_user_assigned_identity.assigned_identity.id]
 }

 app_settings = local.env_variables 
}

resource "azurerm_app_service_slot" "my_app_service_container_staging" {
 name                    = "staging"
 app_service_name        = azurerm_app_service.my_app_service_container.name
 location                = "Australia Southeast"
 resource_group_name     = azurerm_resource_group.MYRG.name
 app_service_plan_id     = azurerm_app_service_plan.my_service_plan.id
 https_only              = true
 client_affinity_enabled = true
 site_config {
   scm_type          = "VSTSRM"
   always_on         = "true"
   health_check_path = "/login"
 }

 identity {
   type         = "SystemAssigned, UserAssigned"
   identity_ids = [azurerm_user_assigned_identity.assigned_identity.id]
 }

 app_settings = local.env_variables
}