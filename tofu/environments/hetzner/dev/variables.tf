variable "admin_cidr" {
  type        = string
  description = "Admin CIDR allowed for SSH"
}

variable "vpn_cidr" {
  type        = string
  description = <<EOT
NetBird VPN subnet range (CIDR).
Supplied dynamically by build-infra.sh via TF_VAR_vpn_cidr.
EOT
}

// Minio Variables for hcloud-server module
variable "minio_root_user" {
  type        = string
  description = "Root username for MinIO (decrypted via SOPS at runtime)."
}

variable "minio_root_password" {
  type        = string
  description = "Root password for MinIO (decrypted via SOPS at runtime)."
  sensitive   = true
}

// Keep a sensible default; increase later if checkpoints grow.
variable "minio_volume_size" {
  type        = number
  description = "Size (GiB) for MinIO persistent volume"
  default     = 100
}

// Add the safety flag (location + snippet)
variable "enable_netbird" {
  description = "Create NetBird controller + firewall when true (repo safety gate)"
  type        = bool
  default     = false
}
