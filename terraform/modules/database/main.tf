
#Creates a postgres sql server
resource "azurerm_postgresql_server" "postgres-master" {
  name                = var.server_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name = var.sku_name
  storage_mb                    = var.storage_mb
  backup_retention_days         = var.backup_retention_days
  geo_redundant_backup_enabled  = var.geo_redundant_backup_enabled
  administrator_login           = var.administrator_login
  administrator_login_password  = var.administrator_password
  version                       = var.server_version
  ssl_enforcement_enabled       = var.ssl_enforcement_enabled
  public_network_access_enabled = var.public_network_access_enabled

  tags = var.tags
}

#Creates a postgres database
resource "azurerm_postgresql_database" "dbs" {
  count               = length(var.db_names)
  name                = var.db_names[count.index]
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.postgres-master.name
  charset             = var.db_charset
  collation           = var.db_collation
}

resource "azurerm_postgresql_configuration" "db_configs" {
  count               = length(keys(var.postgresql_configurations))
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.postgres-master.name

  name  = element(keys(var.postgresql_configurations), count.index)
  value = element(values(var.postgresql_configurations), count.index)
}

/*#Creates a replicate of postgres server
resource "azurerm_postgresql_server" "postgres_standby" {
  count                            = var.replicas_count
  name                             = "${azurerm_postgresql_server.postgres-master.name}-r-${var.replicas_count}"
  location                         = var.replicas_location
  resource_group_name              = var.resource_group_name
  sku_name                         = var.sku_name
  version                          = var.server_version
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
  storage_mb                       = var.storage_mb
  public_network_access_enabled    = var.public_network_access_enabled
  create_mode                      = "Replica"
  creation_source_server_id        = azurerm_postgresql_server.postgres-master.id

  lifecycle {
    ignore_changes = [
      # Autogrow is enabled
      storage_mb,
    ]
  }
}
*/

