# Configuration Azure provider
terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  # Configuration du backend distant pour le state Terraform
  # 
  # IMPORTANT : Pour activer le backend distant :
  # 1. Créez d'abord le Storage Account et le container "tfstate" manuellement, OU
  # 2. Décommentez la configuration backend ci-dessous et configurez les valeurs
  # 3. Exécutez : terraform init -migrate-state (pour migrer le state local vers le backend distant)
  #
  # Exemple de configuration (à décommenter et adapter) :
  # backend "azurerm" {
  #   resource_group_name  = "elecasRG"
  #   storage_account_name = "<nom-du-storage-account-pour-state>"
  #   container_name       = "tfstate"
  #   key                  = "terraform.tfstate"
  # }
  #
  # Note : Le Storage Account pour le backend doit exister AVANT d'initialiser Terraform avec le backend.
  # Vous pouvez utiliser le Storage Account créé par ce projet après le premier déploiement,
  # ou créer un Storage Account dédié pour le state.
}

# Configuration du provider Azure
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
