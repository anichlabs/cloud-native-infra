#!/usr/bin/env bash
set -euo pipefail
trap 'echo "✖ Error on line $LINENO"; exit 1' ERR

# 1. Set environment and root directory
ENV="${1:-dev}"
shift || true
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../tofu/environments/hetzner/${ENV}" && pwd)"
cd "$ROOT"

# 2. Decrypt the Hetzner API token using SOPS and age
echo "→ Decrypting secrets..."
export HCLOUD_TOKEN="$(SOPS_AGE_KEY_FILE="$HOME/.secrets/age.key" \
  sops --decrypt --extract '["hcloud_token"]' hetzner.enc.yaml)"
echo "HCLOUD_TOKEN is set: ****…"

# 2b. Decrypt MinIO root credentials using SOPS and age
export TF_VAR_minio_root_user="$(SOPS_AGE_KEY_FILE="$HOME/.secrets/age.key" \
  sops --decrypt --extract '["minio_root_user"]' hetzner.enc.yaml)"

export TF_VAR_minio_root_password="$(SOPS_AGE_KEY_FILE="$HOME/.secrets/age.key" \
  sops --decrypt --extract '["minio_root_password"]' hetzner.enc.yaml)"

echo "MINIO_ROOT_USER is set: ${TF_VAR_minio_root_user}"
echo "MINIO_ROOT_PASSWORD is set: ****…"  # don’t print the password

# 3. Detect current public IPv4 and inject as admin_cidr
MYIP=$(curl -s -4 ifconfig.co || true)
if [[ -z "$MYIP" ]]; then
  echo "⚠ Could not detect public IP. Falling back to 0.0.0.0/0"
  export TF_VAR_admin_cidr="0.0.0.0/0"
else
  export TF_VAR_admin_cidr="${MYIP}/32"
fi
echo "→ Using admin_cidr = ${TF_VAR_admin_cidr}"

# 4. Set NetBird VPN subnet (static for now, can be made dynamic later)
export TF_VAR_vpn_cidr="100.64.0.0/10"
echo "→ Using vpn_cidr = ${TF_VAR_vpn_cidr}"

# 5. Init and Plan
echo "→ Initializing OpenTofu..."
tofu init -input=false

echo "→ Running plan..."
tofu plan -out=tfplan "$@"

# 6. Apply if APPLY=true is set
if [[ "${APPLY:-false}" == "true" ]]; then
  echo "→ Applying changes..."
  tofu apply -input=false -auto-approve tfplan
else
  echo "✔ Plan complete. Review with: tofu show tfplan"
  echo "⚠ To apply manually, run: tofu apply tfplan"
fi
