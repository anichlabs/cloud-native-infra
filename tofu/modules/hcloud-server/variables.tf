// tofu/modules/hcloud-server/variables.tf
// Purpose: input variables for generic Hetzner server module.
// Notes: defaults kept minimal: GDPR/AI Act compliance by avoiding secrets here.

variable "name" {
  type        = string
  description = "Name of the server (unique, descriptive, e.g. minio-dev-1)"
}

variable "server_type" {
  type        = string
  description = "Hetzner server type (e.g. cx22, cpx21, ccx23)"
  default     = "cx22"
}

variable "image" {
  type        = string
  description = "Base OS image (e.g. ubuntu-24.04)"
  default     = "ubuntu-24.04"
}

variable "region" {
  type        = string
  description = "Region/datacenter (e.g. fsn1, nbg1, hel1)"
}

variable "network_id" {
  type        = string
  description = "ID of the private network to attach"  
}

variable "private_ip" {
  type        = string
  description = "Private IPv4 address to assign inside the network"
}

variable "firewall_id" {
  type        = string
  description = "Firewall ID to apply (optional)"
  default     = null
}

variable "ssh_key_name" {
  type        = string
  description = "Name of the SSH key uploaded to Hetzner"
}

variable "user_data" {
  type        = string
  description = "Cloud-init user data for server bootstrap (optional)"
  default     = null
}

variable "labels" {
  type        = map(string)
  description = "Custom labels for tagging and compliance traceability"
  default     = {}
}

variable "delete_protection" {
  type        = bool
  description = "Enable delete protection (true to avoid accidental destroys)"
  default     = true
}

variable "enable_backups" {
  type        = bool
  description = "Enable Hetzner automated backups (extra cost)"
  default     = false
}