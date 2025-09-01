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

# 3. Init and Plan
echo "→ Initializing OpenTofu..."
tofu init -input=false
echo "→ Running plan..."
tofu plan -out=tfplan "$@"

# 4. Apply if environment variable APPLY=true
if [[ "${APPLY:-false}" == "true" ]]; then
  echo "→ Applying..."
  tofu apply -auto-approve "$@" tfplan
  rm -f tfplan
  echo "✅ Apply complete! (tfplan removed)"
else
  echo "→ Plan created: tfplan. Use APPLY=true load-secrets.sh to apply."
fi
