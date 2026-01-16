# Stage 1: Builder - Installation des dépendances
FROM ghcr.io/astral-sh/uv:python3.11-bookworm-slim AS builder

WORKDIR /app

# Copier uniquement les fichiers de dépendances en premier pour optimiser le cache Docker
# Cette couche sera mise en cache si pyproject.toml ne change pas
COPY pyproject.toml ./

# Installer les dépendances et compiler le bytecode pour optimiser les performances
# --no-dev : exclut les dépendances de développement
# --compile-bytecode : compile les fichiers Python en bytecode pour un démarrage plus rapide
RUN uv sync --no-dev --compile-bytecode

# Stage 2: Runtime - Image finale optimisée
FROM python:3.11-slim-bookworm

# Métadonnées de l'image
LABEL maintainer="Data Engineering Team" \
      description="NYC Taxi Pipeline - Data Engineering Pipeline" \
      version="0.1.0"

# Installation des dépendances système nécessaires (libpq5 pour psycopg2)
# Optimisation : combiner update, install et cleanup en une seule couche RUN
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libpq5 \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Créer un utilisateur non-root pour la sécurité
RUN groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app

# Copier l'environnement virtuel depuis le stage builder
# Cette étape est optimisée : copie uniquement le .venv nécessaire
COPY --from=builder /app/.venv /app/.venv

# Copier le code applicatif en une seule opération pour réduire les layers
# Ordre optimisé : d'abord les fichiers statiques (sql), puis le code Python
COPY --from=builder /app/sql ./sql
COPY --from=builder /app/pipelines ./pipelines
COPY --from=builder /app/utils ./utils
COPY --from=builder /app/main.py ./

# Changer la propriété des fichiers vers l'utilisateur non-root
RUN chown -R appuser:appuser /app

# Passer à l'utilisateur non-root pour la sécurité
USER appuser

# Variables d'environnement optimisées
# PATH : permet d'utiliser les binaires Python du venv sans chemin absolu
# PYTHONUNBUFFERED : désactive le buffering pour voir les logs en temps réel
# PYTHONDONTWRITEBYTECODE : évite de créer des fichiers .pyc (déjà compilés dans le builder)
ENV PATH="/app/.venv/bin:$PATH" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONHASHSEED=random

# Point d'entrée de l'application
# Utilisation de exec form pour éviter un shell wrapper (PID 1 correct)
CMD ["python", "main.py"]