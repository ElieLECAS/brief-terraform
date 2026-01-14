# Container Apps et environnement
# 
# NOTE: Ces ressources sont temporairement commentées car le provider Microsoft.App
# n'est pas enregistré et nécessite des permissions d'administrateur.
# 
# Pour réactiver ces ressources :
# 1. Demandez à un administrateur d'exécuter : az provider register --namespace Microsoft.App
# 2. Vérifiez que le provider est enregistré : az provider show --namespace Microsoft.App
# 3. Décommentez les ressources ci-dessous
# 4. Exécutez : terraform apply

# Container Apps Environment
# resource "azurerm_container_app_environment" "main" {
#   name                = "cae-${var.project_name}-${var.environment}"
#   resource_group_name = data.azurerm_resource_group.main.name
#   location            = data.azurerm_resource_group.main.location
#
#   tags = var.tags
# }

# Container App
# resource "azurerm_container_app" "main" {
#   name                         = "ca-${var.project_name}-pipeline-${var.environment}"
#   container_app_environment_id = azurerm_container_app_environment.main.id
#   resource_group_name          = data.azurerm_resource_group.main.name
#   revision_mode                = "Single"
#
#   template {
#     min_replicas = var.container_apps_min_replicas
#     max_replicas = var.container_apps_max_replicas
#
#     container {
#       name   = "nyc-taxi-pipeline"
#       image  = "${azurerm_container_registry.main.login_server}/nyc-taxi-pipeline:latest"
#       cpu    = var.container_apps_cpu
#       memory = var.container_apps_memory
#
#       # Variables d'environnement
#       env {
#         name  = "AZURE_CONTAINER_NAME"
#         value = azurerm_storage_container.raw.name
#       }
#
#       env {
#         name  = "POSTGRES_HOST"
#         value = "${azurerm_cosmosdb_postgresql_cluster.main.name}.postgres.cosmos.azure.com"
#       }
#
#       env {
#         name  = "POSTGRES_PORT"
#         value = "5432"
#       }
#
#       env {
#         name  = "POSTGRES_DB"
#         value = "citus"
#       }
#
#       env {
#         name  = "POSTGRES_USER"
#         value = var.cosmos_db_admin_username
#       }
#
#       env {
#         name  = "POSTGRES_SSL_MODE"
#         value = "require"
#       }
#
#       env {
#         name  = "START_DATE"
#         value = var.start_date
#       }
#
#       env {
#         name  = "END_DATE"
#         value = var.end_date
#       }
#
#       # Secrets
#       env {
#         name        = "AZURE_STORAGE_CONNECTION_STRING"
#         secret_name = "storage-connection-string"
#       }
#
#       env {
#         name        = "POSTGRES_PASSWORD"
#         secret_name = "postgres-password"
#       }
#
#       env {
#         name        = "ACR_PASSWORD"
#         secret_name = "acr-password"
#       }
#     }
#   }
#
#   # Configuration des secrets
#   secret {
#     name  = "storage-connection-string"
#     value = azurerm_storage_account.main.primary_connection_string
#   }
#
#   secret {
#     name  = "postgres-password"
#     value = var.cosmos_db_admin_password != null ? var.cosmos_db_admin_password : random_password.cosmos_db_password[0].result
#   }
#
#   secret {
#     name  = "acr-password"
#     value = azurerm_container_registry.main.admin_password
#   }
#
#   # Configuration du registre
#   registry {
#     server   = azurerm_container_registry.main.login_server
#     username = azurerm_container_registry.main.admin_username
#     password_secret_name = "acr-password"
#   }
#
#   tags = var.tags
# }
