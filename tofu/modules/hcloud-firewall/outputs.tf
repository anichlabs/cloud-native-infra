output "firewall_id" {
  value       = hcloud_firewall.this.id
  description = "Firewall ID to attach to servers"
}
