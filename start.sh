#!/usr/bin/env sh
set -eu

exec bentoml serve service:SentimentService \
  --host 0.0.0.0 \
  --port "${PORT:-3000}"
