#!/usr/bin/env bash
set -euo pipefail

# Resolve to project root (one directory above this script)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "→ Cleaning Terraform/OpenTofu local caches and state in $PROJECT_ROOT..."

# Safety prompt
read -r -p "⚠  This will delete ALL .terraform/ directories, tfplan files, tfstate files, and stray logs. Continue? [y/N] " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  echo "✖ Cancelled."
  exit 1
fi

# Remove all .terraform directories recursively
find "$PROJECT_ROOT/tofu" -type d -name ".terraform" -prune -exec rm -rf {} +

# Remove all tfplan files
find "$PROJECT_ROOT/tofu" -type f -name "tfplan" -exec rm -f {} +

# Remove all state files (tfstate + backups)
find "$PROJECT_ROOT/tofu" -type f -name "*.tfstate*" -exec rm -f {} +

# Remove stray typescript logs (created if you ever ran the 'script' command)
find "$PROJECT_ROOT/tofu" -type f -name "typescript" -exec rm -f {} +

echo "✔ Clean complete. All .terraform/, tfplan, tfstate, and typescript logs removed."
