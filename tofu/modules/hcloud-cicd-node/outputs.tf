// tofu/modules/hcloud-cicd-node/outputs.tf
// Purpose: minimal outputs for CI logs and downstream wiring (no secrets).

output "server_id" {
  description = "Hetzner server ID for the CI/CD node."
  value       = hcloud_server.this.id         
}

output "public_ipv4" {
  description = "Public IPv4 address (if enabled)."
  value       = hcloud_server.this.ipv4_address
}

output "public_ipv6" {
  description = "Public IPv6 address (if enabled)"
  value       = try(hcloud_server.this.ipv6_address, null) 
}

output "private_ip" {
  description = "Private IP assigned on the Hetzner network."
  value       = hcloud_server_network.this.ip
}

output "firewall_id" {
  description = "Firewall ID attached to the CI/CD node."
  value       = hcloud_firewall.this.id
}

output "labels" {
  description = "Labels applied to the server (avoid PII; include role/env)."
  value       = hcloud_server.this.labels
}