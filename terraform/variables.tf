# Définition des variables

variable "subscription_id" {
  description = "ID de la souscription Azure"
  type        = string
}

variable "project_name" {
  description = "Nom du projet (utilisé pour nommer les ressources)"
  type        = string
  default     = "nyctaxi"
}

variable "environment" {
  description = "Environnement (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Région Azure où déployer les ressources"
  type        = string
  default     = "francecentral"
}

variable "tags" {
  description = "Tags à appliquer à toutes les ressources"
  type        = map(string)
  default = {
    Project     = "NYC Taxi Pipeline"
    ManagedBy   = "Terraform"
    Environment = "dev"
  }
}

# Configuration des pipelines
variable "start_date" {
  description = "Date de début pour le pipeline (format YYYY-MM)"
  type        = string
}

variable "end_date" {
  description = "Date de fin pour le pipeline (format YYYY-MM)"
  type        = string
}

# Cosmos DB Configuration
variable "cosmos_db_admin_username" {
  description = "Nom d'utilisateur administrateur pour Cosmos DB"
  type        = string
  default     = "taxiadmin"
}

variable "cosmos_db_admin_password" {
  description = "Mot de passe administrateur pour Cosmos DB (généré automatiquement si null)"
  type        = string
  sensitive   = true
  default     = null
}

# Container Apps Configuration
variable "container_apps_cpu" {
  description = "Nombre de CPU pour le Container App"
  type        = number
  default     = 0.5
}

variable "container_apps_memory" {
  description = "Mémoire pour le Container App"
  type        = string
  default     = "1Gi"
}

variable "container_apps_min_replicas" {
  description = "Nombre minimum de replicas pour le Container App"
  type        = number
  default     = 0
}

variable "container_apps_max_replicas" {
  description = "Nombre maximum de replicas pour le Container App"
  type        = number
  default     = 1
}

# Backend Terraform Configuration
variable "terraform_backend_enabled" {
  description = "Activer le backend distant pour le state Terraform (nécessite un Storage Account existant)"
  type        = bool
  default     = false
}

variable "terraform_backend_storage_account" {
  description = "Nom du Storage Account pour stocker le state Terraform (doit exister avant)"
  type        = string
  default     = ""
}

variable "terraform_backend_container" {
  description = "Nom du container pour stocker le state Terraform"
  type        = string
  default     = "tfstate"
}