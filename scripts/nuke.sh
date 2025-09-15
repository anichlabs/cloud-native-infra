#!/usr/bin/env bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

# Usage: ./nuke.sh [environment]
ENV="${1:-dev}"

# Resolve paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DESTROY="$SCRIPT_DIR/destroy-infra.sh"
PURGE="$SCRIPT_DIR/purge.sh"

echo "WARNING: You are about to NUKE the environment: ${ENV}"
echo "   This will destroy all Hetzner infrastructure (servers, firewalls, volumes, networks)"
echo "   and wipe local Terraform/OpenTofu artifacts."
read -r -p "Are you absolutely sure? [y/N] " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  echo "Cancelled."
  exit 1
fi

# Step 1: Destroy remote infra
echo "Running destroy-infra.sh ${ENV}..."
"$DESTROY" "${ENV}"

# Step 2: Purge local artifacts
echo "Running purge.sh..."
"$PURGE"

echo "Nuke complete. Both remote infrastructure and local state are gone."
