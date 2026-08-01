# Support

Check `/readyz` first; a non-200 response means the BentoML worker has not become ready. Build failures should be reproduced with `docker compose build`, while API-shape failures should be reproduced with `./scripts/smoke.sh` against a healthy deployment.

This starter deliberately uses a tiny deterministic example model. Replace `model.py` and its tests with your own inference code, update the API types in `service.py`, keep the health check at `/readyz`, and remeasure memory and latency before raising concurrency or worker count.
