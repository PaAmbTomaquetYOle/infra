#!/usr/bin/env bash
set -euo pipefail

wait_for_health() {
  local name="$1"
  local url="$2"
  local attempts="${3:-30}"
  local sleep_seconds="${4:-2}"

  for attempt in $(seq 1 "$attempts"); do
    if curl --fail --silent --show-error "$url" > /dev/null; then
      echo "$name ok -> $url"
      return 0
    fi

    echo "Waiting for $name ($attempt/$attempts) -> $url"
    sleep "$sleep_seconds"
  done

  echo "$name health check failed: $url" >&2
  return 1
}

wait_for_health "slack-agent" "http://localhost:3000/health"
wait_for_health "mcp-server" "http://localhost:8000/health"
wait_for_health "backend" "http://localhost:8001/api/v1/health"

echo "BrainTrust infra smoke checks passed."
