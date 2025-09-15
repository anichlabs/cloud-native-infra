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

// --- TLS Entrypoint / public URLs (keep optional for now)
variable "acme_email" {
  type        = string
  description = "Email for ACME/Let's Encrypt certificate registration (GDPR contact)."
  default     = "chris@anichlabs.com"
}

variable "forgejo_domain" {
  type        = string
  description = "Public domain for Forgejo (e.g. forgejo.dev.anichlabs.com). Leave empty to use public IP."
  default     = ""
}

variable "minio_domain" {
  type        = string
  description = "Public domain for MinIO API (e.g. minio.dev.anichlabs.com). Leave empty to use IP."
  default     = ""
}

variable "minio_console_domain" {
  type        = string
  description = "Public domain for MinIO Console (e.g. minio-console.dev.anichlabs.com). Leave empty to use IP."
  default     = ""
}

variable "monitoring_domain" {
  type        = string
  description = "Public domain for Grafana/Prometheus/Loki (e.g. monitoring.dev.anichlabs.com). Leave empty to use IP."
  default     = ""
}
