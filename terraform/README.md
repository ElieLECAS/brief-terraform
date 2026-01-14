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

## Notes

- Le volume `azure-cli-data` persiste les credentials Azure CLI entre les redémarrages du conteneur
- Après la première authentification, vous n'aurez plus besoin de vous reconnecter (sauf expiration du token)
- Les tokens Azure CLI expirent généralement après quelques heures/jours
