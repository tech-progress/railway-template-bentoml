FROM ghcr.io/astral-sh/uv:0.12.22@sha256:f513a91fc62fe7c17567eee97230dd198e43edb8a9fbecca843714a4358fe1bc AS uv
FROM python:3.12.15-slim-trixie@sha256:29113dcae7aad06daa8e95260fa09f27d62be33b9687ea3774f771d601a02256

ENV BENTOML_DO_NOT_TRACK=True \
    BENTOML_HOME=/home/bentoml/.bentoml \
    HOME=/home/bentoml \
    PATH=/app/.venv/bin:$PATH \
    PYTHONUNBUFFERED=1 \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy

COPY --from=uv /uv /uvx /bin/
WORKDIR /app
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev --no-install-project \
    && useradd --create-home --uid 10001 bentoml
COPY --chown=bentoml:bentoml model.py service.py start.sh ./
RUN chmod 0555 start.sh \
    && mkdir -p /home/bentoml/.bentoml \
    && chown -R bentoml:bentoml /home/bentoml

USER 10001:10001
EXPOSE 3000
CMD ["./start.sh"]
