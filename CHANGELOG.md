# Changelog

## [1.0.1] - 2026-08-01

- Clear the generator seed's start command when restoring a source-backed draft.
- Audit the stored start command so Docker's BentoML command cannot be overridden silently.
- Record the published template contract and standalone-source maintenance instructions.

## [1.0.0] - 2026-08-01

- Add BentoML 1.4.39 with a typed single and batch inference API.
- Pin the Python and uv images, lock Python dependencies, and run as a non-root user.
- Verify model behavior, readiness, OpenAPI discovery, inference, and restart.
