#!/usr/bin/env bash
set -euo pipefail

template_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
required_files=(
  .dockerignore .env.example .gitignore .railway/railway.ts bun.lock CHANGELOG.md
  compose.yaml Dockerfile LICENSE_REVIEW.md MARKETPLACE.md model.py package.json
  PUBLISHING.md pyproject.toml README.md service.py start.sh SUPPORT.md
  template-defaults.json template-descriptions.json template-networking.json
  tests/test_model.py UPGRADE.md uv.lock VERSION scripts/audit-template.sh
  scripts/check-standalone.sh scripts/restore-template-draft.sh scripts/smoke.py
  scripts/smoke.sh scripts/verify.sh
)
for file in "${required_files[@]}"; do
  test -f "${template_root}/${file}" || { echo "Missing required file: ${file}" >&2; exit 1; }
done

version="$(<"${template_root}/VERSION")"
[[ "${version}" =~ ^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$ ]]
grep -Eq "^## \[${version//./\\.}\] - [0-9]{4}-[0-9]{2}-[0-9]{2}$" "${template_root}/CHANGELOG.md"
for file in README.md PUBLISHING.md; do
  grep -Fq "current template release is \`v${version}\`" "${template_root}/${file}"
done
for heading in '# Deploy and Host' '## About Hosting' '## Why Deploy' '## Common Use Cases' '## Dependencies for' '### Deployment Dependencies'; do
  grep -Fq "${heading}" "${template_root}/MARKETPLACE.md"
done
publish_description="CPU-safe BentoML starter with typed inference and batch APIs."
(( ${#publish_description} <= 75 ))

docker compose -f "${template_root}/compose.yaml" config --quiet
for file in template-defaults.json template-descriptions.json template-networking.json; do
  jq empty "${template_root}/${file}"
done
for file in "${template_root}"/scripts/*.sh; do bash -n "${file}"; done
python3 -m py_compile "${template_root}/model.py" "${template_root}/service.py" "${template_root}/scripts/smoke.py"
(cd "${template_root}" && python3 -m unittest discover -s tests)
(cd "${template_root}" && UV_CACHE_DIR="${UV_CACHE_DIR:-/tmp/bentoml-uv-cache}" uv lock --check)

graph_json="$(cd "${template_root}" && ./node_modules/.bin/railway-iac-ts .railway/railway.ts)"
jq -e '
  .graph.resources |
  ([.[] | select(.type == "service") | .name]) == ["BentoML API"] and
  ([.[] | select(.type == "volume")] | length) == 0 and
  ([.[] | select(.name == "BentoML API")][0] |
    .source.repo == "tech-progress/railway-template-bentoml" and
    .source.branch == "release-v1" and
    .build.dockerfilePath == "Dockerfile" and
    .deploy.healthcheckPath == "/readyz" and
    .variables.PORT.value == "3000" and
    .variables.BENTOML_DO_NOT_TRACK.value == "True")
' <<<"${graph_json}" >/dev/null

jq -e --slurpfile descriptions "${template_root}/template-descriptions.json" '
  to_entries | all(. as $service |
    (.value | keys | sort) == ($descriptions[0][$service.key] | keys | sort))
' "${template_root}/template-defaults.json" >/dev/null

grep -Fq 'name = "bentoml"' "${template_root}/uv.lock"
grep -Fq 'version = "1.4.39"' "${template_root}/uv.lock"
for pin in \
  cda9608307dbbfc1769f3b6b1f9abf5f1360de0be720f544d29a7ae2863c47ef \
  47ae396f09c1303b8653019811a8498470603d7ffefc29cb07c88f1f8cb3d19f; do
  grep -Fq "${pin}" "${template_root}/Dockerfile"
done

if find "${template_root}" -type f \( -name .env -o -name '*.local' \) -print -quit | grep -q .; then
  echo "Local secret file found in the template directory." >&2
  exit 1
fi
echo "BentoML template structure, dependency lock, source, variables, and networking are valid."
