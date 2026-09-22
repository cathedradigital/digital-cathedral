#!/usr/bin/env bash
set -Eeuo pipefail

PREVIEW_URL="${1:-${VERCEL_PREVIEW_URL:-}}"
BYPASS_SECRET="${VERCEL_AUTOMATION_BYPASS_SECRET:-}"

if [[ -z "$PREVIEW_URL" ]]; then
  echo "Usage: VERCEL_PREVIEW_URL=https://preview.example.vercel.app $0" >&2
  exit 2
fi

if [[ -z "$BYPASS_SECRET" ]]; then
  echo "ERROR: VERCEL_AUTOMATION_BYPASS_SECRET is not set" >&2
  exit 2
fi

case "$PREVIEW_URL" in
  https://*.vercel.app|https://*.vercel.sh) ;;
  *) echo "ERROR: preview URL must use an approved HTTPS Vercel hostname" >&2; exit 2 ;;
esac

curl --fail-with-body --silent --show-error --location \
  --header "x-vercel-protection-bypass: $BYPASS_SECRET" \
  --header "x-vercel-set-bypass-cookie: true" \
  --header "Accept: text/html" \
  --output /tmp/vercel-preview.html \
  --write-out 'HTTP %{http_code}\n' \
  "$PREVIEW_URL"

grep -qi 'Cathedra\|Cátedra' /tmp/vercel-preview.html || {
  echo "ERROR: preview responded, but the expected application marker was not found" >&2
  exit 1
}

echo "Vercel preview smoke test passed: $PREVIEW_URL"
