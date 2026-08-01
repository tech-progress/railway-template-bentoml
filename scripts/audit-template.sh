#!/usr/bin/env bash
set -euo pipefail

template_id="${1:?Usage: ./scripts/audit-template.sh TEMPLATE_ID [EXPECTED_STATUS]}"
expected_status="${2:-}"
template_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
template_json="$(railway api 'query Audit($id: String!) { template(id: $id) { name status serializedConfig } }' --var "id=${template_id}" --compact)"
graph_json="$(cd "${template_root}" && ./node_modules/.bin/railway-iac-ts .railway/railway.ts)"
desired="$(jq -c '.graph.resources[] | select(.type == "service" and .name == "BentoML API")' <<<"${graph_json}")"
actual="$(jq -c '[.data.template.serializedConfig.services[] | select(.name == "BentoML API")][0]' <<<"${template_json}")"

[[ "$(jq -r '.data.template.name' <<<"${template_json}")" == "BentoML API starter" ]]
[[ -z "${expected_status}" || "$(jq -r '.data.template.status' <<<"${template_json}")" == "${expected_status}" ]]
[[ "$(jq '.data.template.serializedConfig.services | length' <<<"${template_json}")" == "1" ]]

failures=0
expected_repo="$(jq -r '.source.repo' <<<"${desired}")"
actual_repo="$(jq -r '.source.repo | sub("^https://github.com/"; "") | sub("\\.git$"; "")' <<<"${actual}")"
[[ "${actual_repo}" == "${expected_repo}" ]] || failures=$((failures + 1))
for field in branch rootDirectory; do
  [[ "$(jq -r --arg field "${field}" '.source[$field]' <<<"${actual}")" == "$(jq -r --arg field "${field}" '.source[$field]' <<<"${desired}")" ]] || failures=$((failures + 1))
done
for field in builder dockerfilePath; do
  [[ "$(jq -r --arg field "${field}" '.build[$field]' <<<"${actual}")" == "$(jq -r --arg field "${field}" '.build[$field]' <<<"${desired}")" ]] || failures=$((failures + 1))
done
for field in startCommand healthcheckPath healthcheckTimeout; do
  [[ "$(jq -r --arg field "${field}" '.deploy[$field] // ""' <<<"${actual}")" == "$(jq -r --arg field "${field}" '.deploy[$field] // ""' <<<"${desired}")" ]] || failures=$((failures + 1))
done
while IFS= read -r variable; do
  key="$(jq -r '.key' <<<"${variable}")"; expected="$(jq -r '.value' <<<"${variable}")"
  [[ "$(jq -r --arg key "${key}" '.variables[$key].defaultValue // "__MISSING__"' <<<"${actual}")" == "${expected}" ]] || failures=$((failures + 1))
  [[ "$(jq -r --arg key "${key}" '.variables[$key].isOptional // false' <<<"${actual}")" == "false" ]] || failures=$((failures + 1))
  description="$(jq -r --arg key "${key}" '.variables[$key].description // ""' <<<"${actual}")"
  expected_description="$(jq -r --arg key "${key}" '."BentoML API"[$key]' "${template_root}/template-descriptions.json")"
  [[ "${description}" == "${expected_description}" ]] || failures=$((failures + 1))
done < <(jq -c '."BentoML API" | to_entries[]' "${template_root}/template-defaults.json")

[[ "$(jq -r '.networking.serviceDomains["<hasDomain>"].port // 0' <<<"${actual}")" == "3000" ]] || failures=$((failures + 1))
[[ "$(jq '.volumeMounts | length' <<<"${actual}")" == "0" ]] || failures=$((failures + 1))
(( failures == 0 )) || { echo "BentoML template audit failed with ${failures} mismatch(es)." >&2; exit 1; }
echo "Template ${template_id} matches the BentoML source, build, defaults, health check, and networking."
