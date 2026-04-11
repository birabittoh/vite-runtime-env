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

  echo "window.__ENV__ = {" > "$OUTPUT_FILE"

  FIRST=1
  for key in $(echo "$ENV_KEYS" | tr ',' ' '); do
    value=$(printenv "$key" | sed 's/"/\\"/g')

    if [ $FIRST -eq 1 ]; then
      FIRST=0
    else
      echo "," >> "$OUTPUT_FILE"
    fi

    printf "  %s: \"%s\"" "$key" "$value" >> "$OUTPUT_FILE"
  done

  echo "" >> "$OUTPUT_FILE"
  echo "};" >> "$OUTPUT_FILE"

  echo "[vite-runtime-env] env.js generated:"
  cat "$OUTPUT_FILE"
fi

exec "$@"
