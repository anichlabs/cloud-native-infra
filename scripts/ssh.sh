#!/usr/bin/env bash
set -euo pipefail

# Default environment is dev
ENV="${ENV:-dev}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../tofu/environments/hetzner/${ENV}" && pwd)"
cd "$ROOT"

# Make sure a target is passed
TARGET="${1:-}"
if [[ -z "$TARGET" ]]; then
  echo "Usage: $0 <cp|w1|w2|repo|firezone>"
  exit 1
fi

# Fetch outputs from OpenTofu
CP_IP=$(tofu output -raw control_plane_ip 2>/dev/null || true)
WORKER_IPS=$(tofu output -json worker_ips 2>/dev/null || true)

if [[ -z "$CP_IP" || -z "$WORKER_IPS" ]]; then
  echo "✖ Could not fetch IPs. Did you run 'tofu apply'?"
  exit 1
fi

# Map targets to IPs
case "$TARGET" in
  cp)
    HOST="$CP_IP"
    ;;
  w1)
    HOST=$(echo "$WORKER_IPS" | jq -r '.[0]')
    ;;
  w2)
    HOST=$(echo "$WORKER_IPS" | jq -r '.[1]')
    ;;
  repo|firezone)
    echo "✖ Target '$TARGET' not yet defined in outputs. Add it later."
    exit 1
    ;;
  *)
    echo "✖ Unknown target: $TARGET"
    exit 1
    ;;
esac

echo "→ Connecting to $TARGET at $HOST ..."
ssh root@"$HOST"
