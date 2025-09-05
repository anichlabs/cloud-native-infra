#!/usr/bin/env bash
set -euo pipefail
trap 'echo "✖ Error on line $LINENO"; exit 1' ERR

# Usage: ./destroy-infra.sh [environment]
ENV="${1:-dev}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../tofu/environments/hetzner/${ENV}" && pwd)"
cd "$ROOT"

echo "→ Decrypting secrets..."
export HCLOUD_TOKEN="$(SOPS_AGE_KEY_FILE="$HOME/.secrets/age.key" \
  sops --decrypt --extract '["hcloud_token"]' hetzner.enc.yaml)"
echo "HCLOUD_TOKEN is set: ****…"

# Decrypt MinIO credentials (required by variables.tf)
export TF_VAR_minio_root_user="$(SOPS_AGE_KEY_FILE="$HOME/.secrets/age.key" \
  sops --decrypt --extract '["minio_root_user"]' hetzner.enc.yaml)"
export TF_VAR_minio_root_password="$(SOPS_AGE_KEY_FILE="$HOME/.secrets/age.key" \
  sops --decrypt --extract '["minio_root_password"]' hetzner.enc.yaml)"
echo "MINIO_ROOT_USER is set: ${TF_VAR_minio_root_user}"
echo "MINIO_ROOT_PASSWORD is set: ****…"

# Detect current public IP
MYIP=$(curl -s -4 ifconfig.co || true)
if [[ -z "$MYIP" ]]; then
  echo "✖ Failed to detect public IP (curl ifconfig.co)."
  echo "   Falling back to 0.0.0.0/0 (open access)."
  export TF_VAR_admin_cidr="0.0.0.0/0"
else
  export TF_VAR_admin_cidr="${MYIP}/32"
fi
echo "→ Using admin_cidr = ${TF_VAR_admin_cidr}"

# Set NetBird VPN subnet (static for now)
export TF_VAR_vpn_cidr="100.64.0.0/10"
echo "→ Using vpn_cidr = ${TF_VAR_vpn_cidr}"

echo "→ Initializing OpenTofu..."
tofu init -input=false

echo "⚠ You are about to destroy infrastructure in environment: ${ENV}"
tofu destroy -auto-approve -input=false
