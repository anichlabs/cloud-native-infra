// tofu/modules/hcloud-cicd-node/outputs.tf
// Purpose: minimal outputs for CI logs and downstream wiring (no secrets).

output "server_id" {
  description   = "Hetzner server ID for the CI/CD node."
  value         = hcloud_server.this.id         
}

output "public_ipv4" {
  description   = "Public IPv4 address (if enabled)."
  value         = hcloud_server.this.ipv4_address
}

