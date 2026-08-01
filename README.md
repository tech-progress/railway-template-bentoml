# BentoML API starter on Railway

This template deploys a source-backed BentoML `1.4.39` inference API with a tiny deterministic CPU model. Python dependencies are locked, build images are pinned by digest, the process runs as a non-root user, and the current template release is `v1.0.1`.

## Deploy on Railway

Deploy the template, wait for `/readyz` to pass, then open the generated service domain. The root page provides BentoML's API explorer, while `POST /classify` and `POST /classify_batch` provide typed inference endpoints.

No credentials or external services are required. Railway sets `PORT=3000` for HTTP routing, and `BENTOML_DO_NOT_TRACK=True` disables BentoML's anonymous framework telemetry; both variables are created by the template and normally need no changes.

## Try the API

Send `{"text":"The deployment is reliable and excellent."}` to `/classify` for one prediction. Send `{"texts":["excellent", "broken", "plain text"]}` to `/classify_batch` for ordered batch results. The included model is intentionally small and transparent, so replace `model.py` and its tests with your own model before using the service for real decisions.

## Operating boundary

The service uses one worker and no persistent volume because its model ships with the source. Replacing it with a downloaded or trained model may require a volume, more memory, longer health-check timeouts, or external object storage; measure that concrete workload before changing the topology.

The Railway configuration points at `tech-progress/railway-template-bentoml` on `release-v1`. Fork maintainers must change that source in `.railway/railway.ts`, create the same release branch in their repository, and authorize Railway to access it before applying the configuration.
