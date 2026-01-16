# Configuration Terraform

## Authentification Azure

Avant d'exécuter `terraform plan` ou `terraform apply`, vous devez vous authentifier avec Azure CLI dans le conteneur Docker.

### Option 1 : Authentification interactive (recommandée pour la première fois)

```bash
# Entrer dans le conteneur Terraform
docker-compose exec terraform sh

# Dans le conteneur, se connecter à Azure
az login

# Vérifier la connexion
az account show

# Sortir du conteneur
exit
```

### Option 2 : Authentification avec un service principal (pour CI/CD)

```bash
# Dans le conteneur
az login --service-principal \
  --username <APP_ID> \
  --password <PASSWORD> \
  --tenant <TENANT_ID>
```

### Option 3 : Utiliser les credentials de votre machine hôte

Si vous êtes déjà connecté sur votre machine hôte, vous pouvez copier les credentials :

```bash
# Sur votre machine hôte (Windows)
# Les credentials sont dans : %USERPROFILE%\.azure

# Copier le dossier .azure dans le volume Docker
# (Le volume azure-cli-data devrait déjà être monté)
```

## Commandes Terraform

Une fois authentifié :

```bash
# Entrer dans le conteneur
docker-compose exec terraform sh

# Initialiser Terraform (déjà fait normalement)
terraform init

# Valider la configuration
terraform validate

# Voir le plan d'exécution
terraform plan

# Appliquer les changements (ATTENTION : crée des ressources Azure facturées)
terraform apply

# Détruire l'infrastructure
terraform destroy
```

## Gestion du State Terraform

### Backend Local (par défaut)

Par défaut, le state Terraform est stocké localement dans le fichier `terraform.tfstate`. Ce fichier est exclu du contrôle de version (voir `.gitignore`).

### Backend Distant (recommandé pour production)

Pour utiliser un backend distant Azure Storage (recommandé pour le travail en équipe et la production) :

1. **Première option : Utiliser le Storage Account créé par Terraform**
   - Déployez d'abord l'infrastructure avec `terraform apply` (backend local)
   - Récupérez le nom du Storage Account depuis les outputs : `terraform output storage_account_name`
   - Décommentez et configurez le bloc `backend` dans `providers.tf` :
   ```hcl
   backend "azurerm" {
     resource_group_name  = "elecasRG"
     storage_account_name = "<nom-du-storage-account>"
     container_name       = "tfstate"
     key                  = "terraform.tfstate"
   }
   ```
   - Activez la création du container dans `terraform.tfvars` :
   ```hcl
   terraform_backend_enabled = true
   terraform_backend_container = "tfstate"
   ```
   - Migrez le state : `terraform init -migrate-state`

2. **Deuxième option : Utiliser un Storage Account existant**
   - Créez manuellement un Storage Account et un container "tfstate" dans Azure
   - Configurez le backend dans `providers.tf` avec le nom du Storage Account existant
   - Exécutez `terraform init`

**Avantages du backend distant :**
- Partage du state entre membres de l'équipe
- Locking automatique (évite les conflits)
- Historique des versions du state
- Sécurité renforcée

## Notes

- Le volume `azure-cli-data` persiste les credentials Azure CLI entre les redémarrages du conteneur
- Après la première authentification, vous n'aurez plus besoin de vous reconnecter (sauf expiration du token)
- Les tokens Azure CLI expirent généralement après quelques heures/jours
- Le state Terraform contient des informations sensibles : ne jamais le commiter dans Git