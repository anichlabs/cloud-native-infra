#!/usr/bin/env bash
set -euo pipefail

# Usage: ./ssh.sh [cp|w1|w2|w3...|cicd|minio|monitoring|tls] [env]
ROLE="${1:-}"
ENV="${2:-dev}"

if [[ -z "$ROLE" ]]; then
  echo "Usage: $0 [cp|w1|w2|w3...|cicd|minio|monitoring|tls] [env]"
  exit 1
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../tofu/environments/hetzner/${ENV}" && pwd)"
cd "$ROOT"

# Core cluster IPs
CP_IP=$(tofu output -raw control_plane_ip 2>/dev/null || true)
WORKER_IPS=$(tofu output -json worker_ips 2>/dev/null || true)

# Service node IPs
CICD_IP=$(tofu output -raw cicd_private_ipv4 2>/dev/null || true)
MINIO_IP=$(tofu output -raw minio_vault_private_ipv4 2>/dev/null || true)
MONITORING_IP=$(tofu output -raw monitoring_private_ipv4 2>/dev/null || true)
TLS_IP=$(tofu output -raw tls_entrypoint_private_ipv4 2>/dev/null || true)

case "$ROLE" in
  cp)
    HOST="$CP_IP"
    ;;
  w[0-9]*)
    INDEX=$(( ${ROLE:1} - 1 ))   # w1 → 0, w2 → 1, etc.
    HOST=$(echo "$WORKER_IPS" | jq -r ".[$INDEX]" 2>/dev/null || true)
    ;;
  cicd)
    HOST="$CICD_IP"
    ;;
  minio)
    HOST="$MINIO_IP"
    ;;
  monitoring)
    HOST="$MONITORING_IP"
    ;;
  tls)
    HOST="$TLS_IP"
    ;;
  *)
    echo "✖ Unknown role: $ROLE (expected cp, wN, cicd, minio, monitoring, tls)"
    exit 1
    ;;
esac

if [[ -z "$HOST" || "$HOST" == "null" ]]; then
  echo "✖ Could not resolve IP for $ROLE in env $ENV. Did you run build-infra.sh?"
  exit 1
fi

echo "→ Connecting to $ROLE at $HOST (env: $ENV)"
exec ssh -o StrictHostKeyChecking=no -l root "$HOST"
