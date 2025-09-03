// tofu/modules/hcloud-firewall-minio/variables.tf
// Input variables for MinIO firewall.

variable "admin_cidr" {
  type          = string
  description   = "CIDR for admin workstation (for SSH access)"
}

variable "vpn_cidr" {
  type          = string
  description   = "NetBird VPN subnet range (e.g. 100.64.0.0/10)."
}