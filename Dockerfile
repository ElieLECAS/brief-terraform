# Stage 1: Builder
FROM ghcr.io/astral-sh/uv:python3.11-bookworm-slim AS builder

WORKDIR /app

# Copier pyproject.toml
COPY pyproject.toml ./

# Installer les dépendances depuis pyproject.toml
# Note: uv.lock est optionnel - si vous l'avez, vous pouvez l'ajouter et utiliser --frozen
RUN uv sync --no-dev --compile-bytecode

COPY pipelines/ ./pipelines/
COPY utils/ ./utils/
COPY sql/ ./sql/
COPY main.py ./

# Stage 2: Runtime
FROM python:3.11-slim-bookworm

RUN apt-get update && \
    apt-get install -y --no-install-recommends libpq5 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /app/.venv /app/.venv
COPY --from=builder /app/pipelines ./pipelines
COPY --from=builder /app/utils ./utils
COPY --from=builder /app/sql ./sql
COPY --from=builder /app/main.py ./

ENV PATH="/app/.venv/bin:$PATH" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

CMD ["python", "main.py"]