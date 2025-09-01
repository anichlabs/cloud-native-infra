#!/usr/bin/env bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

# 1. Set environment and root directory
ENV="${1:-dev}"
shift || true
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../tofu/environments/hetzner/${ENV}" && pwd)"
cd "$ROOT"

# 2. Decrypt the token using Sops and age
echo "→ Decrypting secrets..."
HETZNER_TOKEN="$(SOPS_AGE_KEY_FILE="$HOME/.secrets/age.key" \
  sops --decrypt --extract '["hcloud_token"]' hetzner.enc.yaml)"
export HCLOUD_TOKEN="$HETZNER_TOKEN"
echo "HCLOUD_TOKEN is set: ****…"

# 3. Detect current public IPv4 and inject as admin_cidr
MYIP=$(curl -s -4 ifconfig.co || true)
if [[ -z "$MYIP" ]]; then
  echo "✖ Failed to detect public IP (curl ifconfig.co). Aborting for safety."
  exit 1
fi
export TF_VAR_admin_cidr="${MYIP}/32"
echo "→ Using admin_cidr = ${TF_VAR_admin_cidr}"

# 4. Init and Plan
echo "→ Initializing OpenTofu..."
tofu init -input=false
echo "→ Running plan..."
tofu plan -out=tfplan "$@"

echo "✔ Plan complete. Review with: tofu show tfplan"
echo "⚠ To apply manually, run: tofu apply tfplan"
