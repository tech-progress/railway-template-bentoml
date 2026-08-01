# Upgrade guide

Treat BentoML, Python, uv, and `uv.lock` as one tested release. Update the exact versions and image digests together, regenerate the lock with `uv lock`, then repeat unit tests, the clean Docker build, HTTP smoke test, and restart test before publishing a new template version.

Read BentoML's release notes before changing the framework because service decorators, generated API schemas, and container behavior can change between minor releases. Keep one worker unless the replacement model is proven safe to duplicate in memory.
