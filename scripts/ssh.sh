#!/usr/bin/env bash
set -euo pipefail

# Usage: ./ssh.sh [cp|w1|w2|w3...|minio|tls|monitoring|cicd|netbird] [env]
ROLE="${1:-}"
ENV="${2:-dev}"

if [[ -z "$ROLE" ]]; then
  echo "Usage: $0 [cp|w1|w2|w3...|minio|tls|monitoring|cicd|netbird] [env]"
  exit 1
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../tofu/environments/hetzner/${ENV}" && pwd)"
cd "$ROOT"

# Detect current public IP and ASN (autonomous system number)
MYIP=$(curl -s -4 ifconfig.co || true)
ASN=$(curl -s https://ipinfo.io/"$MYIP"/org 2>/dev/null || true)

INSIDE_HETZNER=false
if [[ "$ASN" =~ Hetzner ]]; then
  INSIDE_HETZNER=true
fi

# Helper: prefer private if inside Hetzner, else public
resolve_ip() {
  local private="$1"
  local public="$2"
  if $INSIDE_HETZNER && [[ -n "$private" && "$private" != "null" ]]; then
    echo "$private"
  else
    echo "$public"
  fi
}

# Control plane
CP_PRIVATE=$(tofu output -raw control_plane_ip 2>/dev/null || true)
CP_PUBLIC=$(tofu output -raw control_plane_public_ip 2>/dev/null || true)

# Workers
WORKERS_PRIVATE=$(tofu output -json worker_ips 2>/dev/null || echo "[]")
WORKERS_PUBLIC=$(tofu output -json worker_public_ips 2>/dev/null || echo "[]")

# Other services
MINIO_PRIVATE=$(tofu output -raw minio_vault_private_ipv4 2>/dev/null || true)
MINIO_PUBLIC=$(tofu output -raw minio_vault_public_ipv4 2>/dev/null || true)

TLS_PRIVATE=$(tofu output -raw tls_entrypoint_private_ipv4 2>/dev/null || true)
TLS_PUBLIC=$(tofu output -raw tls_entrypoint_public_ipv4 2>/dev/null || true)

MON_PRIVATE=$(tofu output -raw monitoring_private_ipv4 2>/dev/null || true)
MON_PUBLIC=$(tofu output -raw monitoring_public_ipv4 2>/dev/null || true)

CICD_PRIVATE=$(tofu output -raw cicd_private_ipv4 2>/dev/null || true)
CICD_PUBLIC=$(tofu output -raw cicd_public_ipv4 2>/dev/null || true)

NETBIRD_PRIVATE=$(tofu output -raw netbird_private_ip 2>/dev/null || true)
NETBIRD_PUBLIC=$(tofu output -raw netbird_public_ipv4 2>/dev/null || true)

HOST=""
case "$ROLE" in
  cp)
    HOST=$(resolve_ip "$CP_PRIVATE" "$CP_PUBLIC")
    ;;
  w[0-9]*)
    INDEX=$(( ${ROLE#w} - 1 ))
    PRIV=$(echo "$WORKERS_PRIVATE" | jq -r ".[$INDEX]" 2>/dev/null || true)
    PUB=$(echo "$WORKERS_PUBLIC" | jq -r ".[$INDEX]" 2>/dev/null || true)
    HOST=$(resolve_ip "$PRIV" "$PUB")
    ;;
  minio)
    HOST=$(resolve_ip "$MINIO_PRIVATE" "$MINIO_PUBLIC")
    ;;
  tls)
    HOST=$(resolve_ip "$TLS_PRIVATE" "$TLS_PUBLIC")
    ;;
  monitoring)
    HOST=$(resolve_ip "$MON_PRIVATE" "$MON_PUBLIC")
    ;;
  cicd)
    HOST=$(resolve_ip "$CICD_PRIVATE" "$CICD_PUBLIC")
    ;;
  netbird)
    HOST=$(resolve_ip "$NETBIRD_PRIVATE" "$NETBIRD_PUBLIC")
    ;;
  *)
    echo "✖ Unknown role: $ROLE (expected cp, wN, minio, tls, monitoring, cicd, netbird)"
    exit 1
    ;;
esac

if [[ -z "$HOST" || "$HOST" == "null" ]]; then
  echo "✖ Could not resolve IP for $ROLE. Did you run build-infra.sh already?"
  exit 1
fi

if $INSIDE_HETZNER; then
  echo "→ Detected Hetzner ASN ($ASN). Using private IP."
else
  echo "→ Outside Hetzner ($ASN). Using public IP."
fi

echo "→ Connecting to $ROLE at $HOST (env: $ENV)"
exec ssh -o StrictHostKeyChecking=no -l root "$HOST"
