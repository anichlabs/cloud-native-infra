variable "region" {
  type        = string
  description = "Hetzner region (fsn1, nbg1, hel1)"
}

variable "server_type" {
  type        = string
  description = "Hetzner server type (e.g., cpx21, cpx31)"
}

variable "ssh_key_name" {
  type        = string
  description = "SSH key name registered in Hetzner"
}

variable "network_id" {
  type        = string
  description = "Hetzner network ID (from core-network module)"
}

variable "firewall_id" {
  type        = string
  description  = "Hetzner firewall ID to attach"
}

variable "worker_count" {
  type        = number
  description = "Number of worker nodes to create"
}
