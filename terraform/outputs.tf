# Outputs Terraform

# Resource Group
output "resource_group_name" {
  description = "Nom du Resource Group"
  value       = data.azurerm_resource_group.main.name
}

# Storage Account
output "storage_account_name" {
  description = "Nom du Storage Account"
  value       = azurerm_storage_account.main.name
}

output "storage_account_primary_connection_string" {
  description = "Connection string du Storage Account (sensitive)"
  value       = azurerm_storage_account.main.primary_connection_string
  sensitive   = true
}

output "storage_container_raw" {
  description = "Nom du container raw"
  value       = azurerm_storage_container.raw.name
}

output "storage_container_tfstate" {
  description = "Nom du container pour le state Terraform (si activé)"
  value       = var.terraform_backend_enabled && length(azurerm_storage_container.tfstate) > 0 ? azurerm_storage_container.tfstate[0].name : null
}

# Container Registry
output "acr_name" {
  description = "Nom de l'Azure Container Registry"
  value       = azurerm_container_registry.main.name
}

output "acr_login_server" {
  description = "URL du login server ACR"
  value       = azurerm_container_registry.main.login_server
}

output "acr_admin_username" {
  description = "Nom d'utilisateur admin ACR"
  value       = azurerm_container_registry.main.admin_username
}

# Cosmos DB
output "cosmos_db_cluster_name" {
  description = "Nom du cluster Cosmos DB"
  value       = azurerm_cosmosdb_postgresql_cluster.main.name
}

output "cosmos_db_host" {
  description = "Hostname PostgreSQL"
  value       = "${azurerm_cosmosdb_postgresql_cluster.main.name}.postgres.cosmos.azure.com"
}

output "cosmos_db_port" {
  description = "Port PostgreSQL"
  value       = "5432"
}

output "cosmos_db_database" {
  description = "Nom de la base de données"
  value       = "citus"
}

output "cosmos_db_username" {
  description = "Nom d'utilisateur PostgreSQL"
  value       = var.cosmos_db_admin_username
}

output "cosmos_db_password" {
  description = "Mot de passe PostgreSQL (sensitive)"
  value       = var.cosmos_db_admin_password != null ? var.cosmos_db_admin_password : random_password.cosmos_db_password[0].result
  sensitive   = true
}

output "cosmos_db_connection_string" {
  description = "Connection string PostgreSQL complète"
  value       = "postgresql://${var.cosmos_db_admin_username}:${var.cosmos_db_admin_password != null ? var.cosmos_db_admin_password : random_password.cosmos_db_password[0].result}@${azurerm_cosmosdb_postgresql_cluster.main.name}.postgres.cosmos.azure.com:5432/citus?sslmode=require"
  sensitive   = true
}

# Log Analytics
output "log_analytics_workspace_id" {
  description = "ID du Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.id
}

output "log_analytics_workspace_name" {
  description = "Nom du Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.name
}

# Container Apps
output "container_app_environment_name" {
  description = "Nom du Container Apps Environment"
  value       = azurerm_container_app_environment.main.name
}

output "container_app_name" {
  description = "Nom du Container App"
  value       = azurerm_container_app.main.name
}

output "container_app_fqdn" {
  description = "FQDN du Container App"
  value       = azurerm_container_app.main.latest_revision_fqdn
}
