output "private_ip" {
  description = "Private IPv4 of Kubernetes control plane"
  value       = [for n in hcloud_server.cp.network : n.ip][0]
}

output "public_ip" {
  description = "Public IPv4 address of control-plane"
  value       = hcloud_server.cp.ipv4_address
}
