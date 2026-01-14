# Azure Container Registry

resource "azurerm_container_registry" "main" {
  name                = "acr${var.project_name}${var.environment}${random_string.acr_suffix.result}"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = true

  tags = var.tags
}
