

 /*resource "azurerm_app_service_environment" "techdemo_ase" {
  name                         = var.ase_name
  subnet_id                    = var.subnet_id
  resource_group_name = var.resource_group_name
 pricing_tier                 = var.pricing_tier
  front_end_scale_factor       = var.front_end_scale_factor 
  internal_load_balancing_mode = var.internal_load_balancing_mode
  allowed_user_ip_cidrs        = var.allowed_user_ip_cidrs

  cluster_setting {
    name  = "DisableTls1.0"
    value = "1"
  }*/



locals {
 env_variables = {
   DOCKER_REGISTRY_SERVER_URL            = "https://index.docker.io"
   DOCKER_REGISTRY_SERVER_USERNAME       = ""
   DOCKER_REGISTRY_SERVER_PASSWORD       = ""
   WEBSITES_PORT                         =  3000
 }

default_sku_capacity = var.sku["tier"] == "Dynamic" ? null : 2
}
resource "azurerm_user_assigned_identity" "assigned_identity" {
  resource_group_name = var.resource_group_name
  location            = var.location
  name = "User_ACR_pull"
}

#Creates an app service plan
resource "azurerm_app_service_plan" "techdemoplan" {
 name                = var.app_plan_name
 location            = var.location
 resource_group_name = var.resource_group_name
 kind                = var.app_kind
 reserved            = true

 sku {
    capacity = lookup(var.sku, "capacity", local.default_sku_capacity)
    size     = lookup(var.sku, "size", null)
    tier     = lookup(var.sku, "tier", null)
  }
}

#Creates an app service container
resource "azurerm_app_service" "techdemoplan_container" {
 name                    = var.app_name
 location                = var.location
 resource_group_name     = var.resource_group_name
 app_service_plan_id     = azurerm_app_service_plan.techdemoplan.id
 https_only              = true
 client_affinity_enabled = true
 site_config {
   scm_type = "VSTSRM"

   linux_fx_version  = "DOCKER|servian/techchallengeapp:latest" #define the images to usecfor you application
   health_check_path = "/health" # health check required in order that internal app service plan loadbalancer do not loadbalance on instance down
 }


 identity {
   type         = "SystemAssigned, UserAssigned"
   identity_ids = [azurerm_user_assigned_identity.assigned_identity.id]
 }

 app_settings = local.env_variables 

 /*connection_string {
    name  = "Database"
    type  = "PostgreSQL"
    value = "Server=tcp:azurerm_sql_server.sqldb.fully_qualified_domain_name Database=azurerm_sql_database.db.name;User ID=azurerm_sql_server.sqldb.administrator_login;Password=azurerm_sql_server.sqldb.administrator_login_password;Trusted_Connection=False;Encrypt=True;"
  }*/
}


/*#Creates a staging slot for app service plan
resource "azurerm_app_service_slot" "app_service_container_staging" {
 name                    = "staging"
 app_service_name        = azurerm_app_service.techdemoplan_container.name
 location                = "Australia Southeast"
 resource_group_name     = var.resource_group_name
 app_service_plan_id     = azurerm_app_service_plan.techdemoplan.id
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
*/