# Publishing

The current template release is `v1.0.2`. The published template ID is `baf9084f-696c-4be4-9f7c-9bc8c32d0afa`, its code is `bentoml-api-starter`, and its public URL is `https://railway.com/deploy/bentoml-api-starter`. Publish the standalone repository's `release-v1` branch and immutable `v1.0.2` tag before moving the stored template source.

Before marketplace publication, verify a clean Docker build, all unit tests, `/readyz`, the generated OpenAPI document, single inference, batch inference, and a real restart. Deploy the exact stored template graph after publication, repeat those checks through its public domain, record IDs and resource usage in `FINDINGS.md`, then delete source and verification projects.

This release retains BentoML `1.4.39`, uses Python `3.12.15` on Debian Trixie and uv `0.12.22`, and refreshes `uv.lock` with that uv version. Run the local verifier with uv `0.12.22` before release; no cloud deployment is needed for maintenance-only validation.
