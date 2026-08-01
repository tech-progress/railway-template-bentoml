#!/usr/bin/env sh
set -eu

template_root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
cd "${template_root}"
BENTOML_SMOKE_URL="${BENTOML_SMOKE_URL:-http://127.0.0.1:3000}" \
  python3 scripts/smoke.py
