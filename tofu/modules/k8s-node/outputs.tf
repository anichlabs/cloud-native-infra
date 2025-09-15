// Output: list of worker IPs
output "ips" {
  description = "Private IPv4 addresses of worker nodes"
  value       = [for w in hcloud_server.worker : [for n in w.network : n.ip][0]]
}

output "public_ips" {
  description = "Public IPv4 addresses of worker nodes"
  value       = [for w in hcloud_server.worker : w.ipv4_address]
}
