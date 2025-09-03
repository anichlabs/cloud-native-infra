variable "name" {
  type         = string
  description  = "Firewall name"
  default      = "k8s-firewall"
}

variable "admin_cidr" {
  type         = string
  description  = "Admin CIDR allowed for SSH (e.g., 203.0.113.5/32)"
}

variable "cluster_cidr" {
  type         = string
  description  = "Private network CIDR for infra-cluster traffic (e.g., 10.0.0.0/16)"
}
