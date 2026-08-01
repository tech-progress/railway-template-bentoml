# Deploy and Host BentoML API starter on Railway

Deploy a source-backed BentoML inference service with a tiny CPU-safe example model, typed single and batch APIs, built-in readiness checks, and an interactive API explorer.

## About Hosting BentoML API starter

BentoML is an Apache-2.0 framework for turning Python inference code into online API services. This starter pins BentoML 1.4.39 and its complete dependency graph while keeping the example model small enough to build and run without a GPU or external model download.

## Why Deploy BentoML API starter on Railway

Railway builds the service directly from a public source repository, routes its generated domain to BentoML, and waits for `/readyz` before marking a deployment healthy. The starter gives model teams a reproducible boundary they can customize without inheriting an all-in-one AI platform.

## Common Use Cases

- Prototype a typed inference API before connecting a production model.
- Replace the example classifier with a custom CPU-safe Python model.
- Test BentoML client integration, batch requests, and deployment health behavior.
- Use the generated OpenAPI explorer to agree on an inference contract.

## Dependencies for BentoML API starter

The deployment uses BentoML 1.4.39 on Python 3.12.11. It has no database, external API, model registry, or GPU dependency.

### Deployment Dependencies

- Use a Railway service with enough memory for the replacement model, because the bundled example needs only a small CPU allocation.
