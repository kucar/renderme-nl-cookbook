#!/usr/bin/env bash
# Quick helper to submit a RenderMe job from a template file and download the resulting MP4.
# Requires: curl, python3
set -euo pipefail

API_URL="https://renderme.nl/api/v1"
API_KEY="${RENDERME_API_KEY:-}"
TEMPLATE_FILE="${1:-}"
OUTPUT_FILE="${2:-renderme-output.mp4}"
POLL_SECONDS=3

usage() {
  cat <<'USAGE'
Usage: render_from_template.sh <template.json> [output.mp4]
Environment:
  RENDERME_API_KEY  (required) API key for https://renderme.nl
USAGE
}

if [[ -z "${TEMPLATE_FILE}" || ! -f "${TEMPLATE_FILE}" ]]; then
  echo "Error: template file not found or not provided." >&2
  usage
  exit 1
fi

if [[ -z "${API_KEY}" ]]; then
  echo "Error: RENDERME_API_KEY is required." >&2
  usage
  exit 1
fi

# Submit job
JOB_RESPONSE=$(curl -sS -X POST "${API_URL}/jobs" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  --data @"${TEMPLATE_FILE}")

JOB_ID=$(python3 - <<'PY'
import json,sys
resp=json.loads(sys.stdin.read())
print(resp.get("id",""))
PY
<<<"${JOB_RESPONSE}")

if [[ -z "${JOB_ID}" ]]; then
  echo "Error: Could not extract job id from response: ${JOB_RESPONSE}" >&2
  exit 1
fi

echo "Submitted job ${JOB_ID}. Polling for completion..."
STATUS=""
while :; do
  STATUS_RESPONSE=$(curl -sS -X GET "${API_URL}/jobs/${JOB_ID}" \
    -H "Authorization: Bearer ${API_KEY}")
  STATUS=$(python3 - <<'PY'
import json,sys
resp=json.loads(sys.stdin.read())
print(resp.get("status",""))
PY
<<<"${STATUS_RESPONSE}")
  echo "Status: ${STATUS}"
  if [[ "${STATUS}" == "completed" ]]; then
    break
  elif [[ "${STATUS}" == "failed" || "${STATUS}" == "canceled" ]]; then
    echo "Job ended with status ${STATUS}. Response: ${STATUS_RESPONSE}" >&2
    exit 1
  fi
  sleep "${POLL_SECONDS}"
done

echo "Downloading MP4 to ${OUTPUT_FILE}..."
curl -sS -L -o "${OUTPUT_FILE}" "${API_URL}/jobs/${JOB_ID}/download" \
  -H "Authorization: Bearer ${API_KEY}"
echo "Done. File saved to ${OUTPUT_FILE}."
