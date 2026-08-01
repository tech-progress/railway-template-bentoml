#!/usr/bin/env python3
from __future__ import annotations

import json
import os
import urllib.request


base_url = os.environ.get("BENTOML_SMOKE_URL", "http://127.0.0.1:3000").rstrip("/")


def get(path: str) -> tuple[int, bytes]:
    with urllib.request.urlopen(f"{base_url}{path}", timeout=30) as response:
        return response.status, response.read()


def post(path: str, payload: dict[str, object]) -> object:
    request = urllib.request.Request(
        f"{base_url}{path}",
        data=json.dumps(payload).encode(),
        headers={"Content-Type": "application/json"},
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        if response.status != 200:
            raise SystemExit(f"{path} returned {response.status}")
        return json.loads(response.read())


status, _ = get("/readyz")
if status != 200:
    raise SystemExit(f"readiness returned {status}")

_, schema = get("/docs.json")
paths = json.loads(schema).get("paths", {})
if "/classify" not in paths or "/classify_batch" not in paths:
    raise SystemExit("OpenAPI schema does not expose both inference endpoints")

single = post("/classify", {"text": "The deployment is reliable and excellent."})
if single.get("label") != "positive" or single.get("confidence", 0) <= 0.5:
    raise SystemExit(f"unexpected single prediction: {single}")

batch = post("/classify_batch", {"texts": ["excellent", "broken", "plain text"]})
if [prediction.get("label") for prediction in batch] != ["positive", "negative", "neutral"]:
    raise SystemExit(f"unexpected batch prediction: {batch}")

print("BentoML readiness, OpenAPI, single inference, and batch inference checks passed.")
