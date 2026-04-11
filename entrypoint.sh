#!/bin/sh
set -e

APP_DIR=${APP_DIR:-/usr/share/nginx/html}
OUTPUT_FILE="$APP_DIR/env.js"

echo "[vite-runtime-env] Starting..."

if [ -z "$ENV_KEYS" ]; then
  echo "[vite-runtime-env] No ENV_KEYS provided, skipping env.js generation."
  # Remove existing env.js if any, to avoid using stale config
  rm -f "$OUTPUT_FILE"
else
  echo "[vite-runtime-env] Generating env.js..."

  # Warn about keys that are not set
  for key in $(echo "$ENV_KEYS" | tr ',' ' '); do
    printenv "$key" > /dev/null 2>&1 || echo "[vite-runtime-env] Warning: $key is not set, using empty string."
  done

  # Build the object in a single jq call using the $ENV builtin
  obj=$(jq -n '
    (env.ENV_KEYS | split(",")) as $keys |
    [ $keys[] | {key: ., value: ($ENV[.] // "")} ] | from_entries
  ')

  printf 'window.__ENV__ = %s;\n' "$obj" > "$OUTPUT_FILE"

  echo "[vite-runtime-env] env.js generated:"
  cat "$OUTPUT_FILE"
fi

exec "$@"
