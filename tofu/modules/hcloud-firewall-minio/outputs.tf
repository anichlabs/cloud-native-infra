// tofu/modules/hcloud-firewall-minio/outputs.tf
// Export firewall ID for attachment to MinIO server.

output "firewall_id" {
  description = "ID of the MinIO firewall resource"
  value       = hcloud_firewall.this.id
}
