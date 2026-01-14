# Resource Group, randoms

# Data source pour utiliser le groupe de ressources existant
data "azurerm_resource_group" "main" {
  name = "elecasRG"
}

# Random string pour garantir l'unicité du nom du Storage Account
resource "random_string" "storage_suffix" {
  length  = 8
  special = false
  upper   = false
  numeric = true
}

# Random string pour garantir l'unicité du nom du Container Registry
resource "random_string" "acr_suffix" {
  length  = 6
  special = false
  upper   = false
  numeric = true
}

# Random string pour garantir l'unicité du nom du Cosmos DB
resource "random_string" "cosmos_suffix" {
  length  = 6
  special = false
  upper   = false
  numeric = true
}

# Random password pour Cosmos DB si non fourni
resource "random_password" "cosmos_db_password" {
  count   = var.cosmos_db_admin_password == null ? 1 : 0
  length  = 16
  special = true
}

# NOTE: Le provider Microsoft.App doit être enregistré manuellement avant d'exécuter terraform apply
# Exécutez: az provider register --namespace Microsoft.App
# Cela nécessite des permissions d'administrateur sur l'abonnement
