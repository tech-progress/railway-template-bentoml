FROM ghcr.io/astral-sh/uv:0.8.9@sha256:cda9608307dbbfc1769f3b6b1f9abf5f1360de0be720f544d29a7ae2863c47ef AS uv
FROM python:3.12.11-slim@sha256:47ae396f09c1303b8653019811a8498470603d7ffefc29cb07c88f1f8cb3d19f

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
