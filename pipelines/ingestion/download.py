import os
import sys
from datetime import datetime
from pathlib import Path

# Ajouter le répertoire racine au PYTHONPATH
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from dateutil.relativedelta import relativedelta
from dotenv import load_dotenv
from loguru import logger

from utils.download_helper import (
    build_file_path,
    build_url_from_template,
    download_file_from_url,
    save_file_locally,
    upload_file_to_azure,
)

load_dotenv()


def generer_liste_mois(date_debut, date_fin=None):
    debut = datetime.strptime(date_debut, "%Y-%m")

    if not date_fin:
        fin = datetime.now()
    else:
        fin = datetime.strptime(date_fin, "%Y-%m")

    liste_mois = []
    date_courante = debut

    while date_courante <= fin:
        liste_mois.append((date_courante.year, date_courante.month))
        date_courante += relativedelta(months=1)

    return liste_mois


def telecharger_fichier(annee, mois):
    url_template = (
        "https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_{annee}-{mois:02d}.parquet"
    )

    url = build_url_from_template(url_template, annee=annee, mois=mois)

    return download_file_from_url(url, timeout=60)


def sauvegarder_local(contenu, annee, mois):
    nom_fichier = f"yellow_tripdata_{annee}-{mois:02d}.parquet"
    chemin = build_file_path("data/raw", nom_fichier)
    return save_file_locally(contenu, chemin)


def uploader_vers_azure(contenu, annee, mois):
    container_name = os.getenv("AZURE_CONTAINER_NAME", "raw")
    blob_name = f"yellow_tripdata_{annee}-{mois:02d}.parquet"
    return upload_file_to_azure(
        contenu, blob_name=blob_name, container_name=container_name, create_container=True
    )


def obtenir_3_derniers_mois():
    """
    Retourne les 3 derniers mois disponibles (mois actuel et 2 mois précédents).
    """
    maintenant = datetime.now()
    liste_mois = []
    
    # Commencer par le mois actuel et remonter de 2 mois
    for i in range(3):
        date = maintenant - relativedelta(months=i)
        liste_mois.append((date.year, date.month))
    
    return liste_mois


def telecharger_donnees_taxi():
    """
    Télécharge les 3 derniers fichiers disponibles.
    """
    # Obtenir les 3 derniers mois
    liste_mois = obtenir_3_derniers_mois()

    logger.info(f"Téléchargement des 3 derniers fichiers disponibles")
    logger.info(f"Période : {liste_mois[-1][0]}-{liste_mois[-1][1]:02d} à {liste_mois[0][0]}-{liste_mois[0][1]:02d}")
    logger.info(f"{len(liste_mois)} fichiers à télécharger\n")

    use_azure = os.getenv("AZURE_STORAGE_CONNECTION_STRING") is not None

    if use_azure:
        logger.info("Mode Azure activé")
    else:
        logger.info("Mode local activé (pas de credentials Azure)")

    fichiers_telecharges = 0
    for annee, mois in liste_mois:
        logger.info(f"Téléchargement du fichier {annee}-{mois:02d}...")
        contenu = telecharger_fichier(annee, mois)

        if contenu is None:
            logger.warning(f"⚠ Fichier {annee}-{mois:02d} non disponible, passage au suivant")
            continue

        if use_azure:
            if uploader_vers_azure(contenu, annee, mois):
                logger.success(f"✓ Fichier {annee}-{mois:02d} uploadé vers Azure")
                fichiers_telecharges += 1
            else:
                logger.error(f"✗ Échec de l'upload du fichier {annee}-{mois:02d}")
        else:
            if sauvegarder_local(contenu, annee, mois):
                logger.success(f"✓ Fichier {annee}-{mois:02d} sauvegardé localement")
                fichiers_telecharges += 1
            else:
                logger.error(f"✗ Échec de la sauvegarde du fichier {annee}-{mois:02d}")

    logger.success(f"\nTéléchargement terminé : {fichiers_telecharges}/{len(liste_mois)} fichiers téléchargés avec succès")


if __name__ == "__main__":
    logger.info("Démarrage de la Pipeline 1 : Téléchargement des données\n")
    telecharger_donnees_taxi()
