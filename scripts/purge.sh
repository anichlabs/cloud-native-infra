#!/usr/bin/env bash
set -euo pipefail

# Resolve to project root (one directory above this script)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "→ Purging Terraform/OpenTofu generated artifacts in $PROJECT_ROOT..."

# Remove all .terraform working directories
find "$PROJECT_ROOT/tofu" -type d -name ".terraform" -prune -exec rm -rf {} +

# Remove provider/plugin lock files
find "$PROJECT_ROOT/tofu" -type f -name ".terraform.lock.hcl" -exec rm -f {} +

# Remove all plan files
find "$PROJECT_ROOT/tofu" -type f -name "tfplan" -exec rm -f {} +

# Remove all state files (terraform.tfstate + backups)
find "$PROJECT_ROOT/tofu" -type f -name "*.tfstate*" -exec rm -f {} +

# Remove crash logs (if a plan/apply crashed)
find "$PROJECT_ROOT/tofu" -type f -name "crash.log" -exec rm -f {} +

echo "✔ Purge complete. Only your .tf, .yaml, and source files remain."
