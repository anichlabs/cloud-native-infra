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
  value = module.k8s_control_plane.ip
}

output "worker_ips" {
  value = module.k8s_nodes.ips
}  

// MinIO / Backup Vaults outputs
// Purpose: show where to connect after deployment (public + private IPs).

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