#!/usr/bin/env bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

ENV="${1:-dev}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../tofu/environments/hetzner/${ENV}" && pwd)"
cd "$ROOT"

# Decrypt and set the token
echo "→ Decrypting secrets..."
export HCLOUD_TOKEN="$(SOPS_AGE_KEY_FILE="$HOME/.secrets/age.key" sops --decrypt --extract '["hcloud_token"]' hetzner.enc.yaml)"
echo "HCLOUD_TOKEN is set: ****…"

# Set admin CIDR (if needed)
MYIP=$(curl -s -4 ifconfig.co || true)
if [[ -z "$MYIP" ]]; then
  echo "✖ Failed to detect public IP (curl ifconfig.co). Aborting for safety."
  exit 1
fi
export TF_VAR_admin_cidr="${MYIP}/32"
echo "→ Using admin_cidr = ${TF_VAR_admin_cidr}"

# Initialize and destroy
echo "→ Initializing OpenTofu..."
tofu init -input=false
echo "→ Destroying infrastructure..."
tofu destroy -auto-approve
