output "network_id" {
  description = "Hetzner Cloud network ID"
  value       = module.core_network.network_id
}

output "network_name" {
  description = "Hetzner Cloud network name"
  value       = module.core_network.network_name
}

output "network_ip_range" {
  description = "Hetzner Cloud network IP range"
  value       = module.core_network.network_ip_range
}

output "control_plane_ip" {
  description = "Private IPv4 of Kubernetes control plane"
  value       = module.k8s_control_plane.ip
}

output "worker_ips" {
  description = "Private IPv4 addresses of Kubernetes workers"
  value       = module.k8s_nodes.ips
}

# ──────────────────────────────────────────────────────────────
# MinIO / Backup Vault outputs
# Purpose: show where to connect after deployment (public + private IPs).
# ──────────────────────────────────────────────────────────────

output "minio_vault_public_ipv4" {
  description = "Public IPv4 address of the MinIO vault server"
  value       = module.minio_vault.ipv4_address
}

output "minio_vault_private_ipv4" {
  description = "Private IPv4 address of the MinIO vault server (inside Hetzner network)"
  value       = module.minio_vault.private_network_ip
}

output "minio_vault_labels" {
  description = "Labels attached to the MinIO vault server"
  value       = module.minio_vault.labels
}

# ──────────────────────────────────────────────────────────────
# TLS Entrypoint outputs
# ──────────────────────────────────────────────────────────────

output "tls_entrypoint_public_ipv4" {
  description = "Public IPv4 of TLS Entrypoint"
  value       = module.tls_entrypoint.ipv4_address
}

output "tls_entrypoint_private_ipv4" {
  description = "Private IPv4 of TLS Entrypoint"
  value       = module.tls_entrypoint.private_network_ip
}

output "minio_api_url" {
  description = "MinIO API HTTPS endpoint"
  value       = "https://minio.dev.anichlabs.com"
}

output "minio_console_url" {
  description = "MinIO Console HTTPS endpoint"
  value       = "https://minio-console.dev.anichlabs.com"
}

// ───────────────────────────
// NetBird Controller Outputs
// ───────────────────────────

// Public IPv4
output "netbird_public_ipv4" {
  description = "NetBird controller public IPv4"
  value       = module.netbird_controller.public_ipv4
}

// Public IPv6 (if enabled)
output "netbird_public_ipv6" {
  description = "NetBird controller public IPv6"
  value       = module.netbird_controller.public_ipv6
}

// Private IP (VPC address)
output "netbird_private_ip" {
  description = "NetBird controller private IP in 10.0.0.0/24"
  value       = module.netbird_controller.private_ip
}
