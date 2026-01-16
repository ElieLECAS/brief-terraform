# Storage Account et containers

# Storage Account
resource "azurerm_storage_account" "main" {
  name                     = "st${var.project_name}${var.environment}${random_string.storage_suffix.result}"
  resource_group_name      = data.azurerm_resource_group.main.name
  location                 = data.azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  tags = var.tags
}

# Container pour les données brutes
resource "azurerm_storage_container" "raw" {
  name                  = "raw"
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}

# Container pour les données traitées
resource "azurerm_storage_container" "processed" {
  name                  = "processed"
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}

# Container pour le state Terraform (si backend distant activé)
# Note: Ce container sera créé dans le Storage Account principal ou dans un Storage Account spécifié
resource "azurerm_storage_container" "tfstate" {
  count                 = var.terraform_backend_enabled ? 1 : 0
  name                  = var.terraform_backend_container
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}
