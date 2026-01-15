# Cosmos DB for PostgreSQL

# Cosmos DB Cluster
resource "azurerm_cosmosdb_postgresql_cluster" "main" {
  name                            = "cosmos-${var.project_name}-${var.environment}-${random_string.cosmos_suffix.result}"
  resource_group_name             = data.azurerm_resource_group.main.name
  location                        = data.azurerm_resource_group.main.location
  administrator_login_password    = var.cosmos_db_admin_password != null ? var.cosmos_db_admin_password : random_password.cosmos_db_password[0].result
  coordinator_storage_quota_in_mb = 32768
  coordinator_vcore_count         = 1
  node_count                      = 0
  coordinator_server_edition       = "BurstableMemoryOptimized"

  tags = var.tags
}

# Firewall rule pour autoriser les services Azure
resource "azurerm_cosmosdb_postgresql_firewall_rule" "allow_azure_services" {
  name                = "AllowAzureServices"
  cluster_id          = azurerm_cosmosdb_postgresql_cluster.main.id
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}
