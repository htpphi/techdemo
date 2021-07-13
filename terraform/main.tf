
# Create a new Resource Group
resource "azurerm_resource_group" "MYRG" {
  name     = "MYRG"
  location = "australiaeast"
}

#Module to create postgres server and database
module "postgresql-primary" {
  source = "./modules/database"

  resource_group_name = azurerm_resource_group.MYRG.name
  location            = azurerm_resource_group.MYRG.location

  server_name                   = "example-server5122"
  sku_name                      = "GP_Gen5_2"
  storage_mb                    = 5120
  backup_retention_days         = 7
  geo_redundant_backup_enabled  = false
  administrator_login           = "admin21321"
  administrator_password        = "p@ssw0rd!@#"
  server_version                = "9.5"
  ssl_enforcement_enabled       = true
  public_network_access_enabled = true
  db_names                      = ["my_db1", "my_db2"]
  db_charset                    = "UTF8"
  db_collation                  = "English_United States.1252"


  postgresql_configurations = {
    backslash_quote = "on",
  }

  depends_on = [azurerm_resource_group.MYRG]
}

#Creates an app service plan in australia south east
module "app_service_plan"{
  source = "./modules/services/"
  app_plan_name         = "auseTechDemoServicePlan"
  location              = "Australia Southeast"
  resource_group_name   = azurerm_resource_group.MYRG.name
  app_kind              = "Linux"
  app_name                = "myappservicecontainer"

  sku = {
    tier = "Basic"
    size = "B2"
    capacity  = "1"
  }
}

module "app_service_plan2"{
  source = "./modules/services/"
  app_plan_name         = "aseTechDemoServicePlan"
  location              = "Australia East"
  resource_group_name   = azurerm_resource_group.MYRG.name
  app_kind              = "Linux"
  app_name                = "myappservicecontainer2"
  sku = {
    tier = "Basic"
    size = "B2"
    capacity  = "1"
  }
}
/*#Create an app service container
module "app_service_container"{
source = "./modules/services/"

 location                = "Australia southeast"
 resource_group_name     = azurerm_resource_group.MYRG.name
 app_kind              = "Linux"
 app_service_plan_id     = module.app_service_plan.azurerm_app_service_plan.techdemoplan.id
}*/