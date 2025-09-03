// Output: list of worker IPs
output "ips" {
  value = [for w in hcloud_server.worker : w.ipv4_address]
}
