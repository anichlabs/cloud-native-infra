// tofu/modules/hcloud-cicd-node/variables.tf
// Purpose: inputs for a minimal, GDPR-aware CI/CD node, consistent with existing modules.
// Compliance: avoid secrets here; keep data EU-resident; prefer least privilege by default.

variable "name" {
  type          = string
  description   = "Hostname for the CI/CD node (e.g., cicd-dev-1). Use unique, descriptive names."
}

variable "server_type" {
  type          = string
  description   = "Hetzner server type (e.g., cx22, cpx21, cxx23). Start small; scale later."
  default       = "cx22"
}

variable "image" {
  type          = string
  description   = "Base OS image. Prefer LTS for security updates."
  default       = "ubuntu-24.04"
}

variable "region" {
  type          = string
  description   = "Hetzner location code (hel1|nbg1|fsn1). Keep workloads in the EU for GDPR."
  default       = "hel1"
}

variable "ssh_key_ids" {
  type          = list(string)
  description   = "Hetzner private network ID for east-west traffic and monitoring."
}

variable "network_id" {
  type          = string
  description = "Hetzner private network ID for east-west traffic and monitoring."
}

variable "private_ip" {
  type          = string
  description   = "Optional static private IP within the network (leave null for auto)."
  default       = null
}

variable "enable_public_ipv4" {
  type          = bool
  description   = "Attach public IPv4 for outbound updates/OCI pulls (disable if using NAT/GW)."
  default       = true
}

variable "enable_ipv6" {
  type          = bool
  description   = "Enable IPv6 only when firewall, DNS, and monitoring are ready for it."
  default       = false
}

variable "admin_cidrs" {
  type          = list(string)
  description   = "CIDRs allowed for SSH (22/tcp). Keep empty to keep SSH closed until ready."
  default       = []
}

variable "enable_netbird" {
  type          = bool
  description   = "Open UDP/51820 for NetBird only when the control plane is configured."
  default       = false
}

variable "container_runtime" {
  type          = string
  description   = "Container runtime for runners; prefer 'podman'(rootless) for least privilege."
  default       = "podman"
  validation {
    condition       = contains(["podman", "docker"], var.container_runtime)
    error_message   = "Use 'podman' or 'docker'."
  }
}

variable "user" {
  type          = string
  description   = "Primary login user on the node (typically 'ubuntu')."
  default       = "ubuntu"
}

variable "labels" {
  type          = map(string)
  description   = "Custom labels for tagging and audit (avoid PII; include role, env, managed_by=tofu)."
  default       = {}
}

variable "delete_protection" {
  type          = bool
  description   = "Enable delete protection to avoid accidental destroys."
  default       = true
}

variable "enable_backups" {
  type          = bool
  description = "Enable automated backups (extra cost; decide per environment)."
}
