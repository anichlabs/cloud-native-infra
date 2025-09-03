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

variable "private_ip" {
  type        = string
  description = "Fixed private IP for control-plane node (e.g., 10.0.0.10)"
}

variable "firewall_id" {
  type        = string
  description = "Hetzner firewall ID to attach"
}