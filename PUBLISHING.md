# Publishing

The current template release is `v1.0.0`. Publish the standalone repository's `release-v1` branch and immutable `v1.0.0` tag, then create a Railway source project from `.railway/railway.ts`.

Before marketplace publication, verify a clean Docker build, all unit tests, `/readyz`, the generated OpenAPI document, single inference, batch inference, and a real restart. Deploy the exact stored template graph after publication, repeat those checks through its public domain, record IDs and resource usage in `FINDINGS.md`, then delete source and verification projects.
