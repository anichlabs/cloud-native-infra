// tofu/modules/hcloud-server/outputs.tf
// Purpose: export useful server attribute to be consumed by environments.
// Notes: do not expose secrets; only metadata and IDs.

output "id" {
  description = "Hetzner server ID"
  value       = hcloud_server.this.id
}

output "name" {
  description = "Server name"
  value       = hcloud_server.this.name
}

output "ipv4_address" {
  description = "Public IPv4 address"
  value       = hcloud_server.this.ipv4_address
}

output "ipv6_address" {
  description = "Public IPv6 address"
  value       = hcloud_server.this.ipv6_address
}

output "private_network_ip" {
  description = "Private IPv4 address inside the attached network"
  value       = try(one(hcloud_server.this.network).ip, null)
}


output "labels" {
  description  = "Labels applied to the server"
  value        = hcloud_server.this.labels
}