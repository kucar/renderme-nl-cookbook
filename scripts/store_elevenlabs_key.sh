#!/usr/bin/env bash
# Store your ElevenLabs API key for RenderMe TTS usage.
set -euo pipefail

API_URL="https://renderme.nl/api/v1"
API_KEY="${RENDERME_API_KEY:-}"
ELEVENLABS_KEY="${1:-${ELEVENLABS_API_KEY:-}}"

usage() {
  cat <<'USAGE'
Usage: store_elevenlabs_key.sh <elevenlabs_api_key>

Environment:
  RENDERME_API_KEY      (required) RenderMe API key
  ELEVENLABS_API_KEY    (optional) If not passed as an argument
USAGE
}

if [[ -z "${API_KEY}" ]]; then
  echo "Error: RENDERME_API_KEY is required." >&2
  usage
  exit 1
fi

if [[ -z "${ELEVENLABS_KEY}" ]]; then
  echo "Error: ElevenLabs API key is required." >&2
  usage
  exit 1
fi

echo "Storing ElevenLabs key..."
curl -sS -X POST "${API_URL}/users/elevenlabs-key" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d "{\"elevenlabs_api_key\":\"${ELEVENLABS_KEY}\"}"

echo "Done. You can now render TTS templates."
