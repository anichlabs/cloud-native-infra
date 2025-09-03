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
