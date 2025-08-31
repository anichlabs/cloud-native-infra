// Module: headscale-server
// Purpose: Provision a dedicated Headscale control server in Hetzner (EU).
// Compliance: EU region by default (fsn1). Ingress is least-privilege.
// Post-bootstrap: remove SSH and rely on Tailnet identities (Zero Trust).

// ---------- Inputs ----------
variable "region" {
  type        = string
  description = "Hetzner region (fsn1, nbg1, hel1)"
  default     = "fsn1"  // Keep control-plane in EU jurisdiction.
}

variable "server_type" {
  type		= string
  description	= "Hetzner server type (e.g., cx22, cax11)"
  default	= "cx22"  // Headscale is lightweight; 2vCPU/4GB is ample.
}

variable "ssh_key_name" {
  type		= string
  description   = "SSH key name registered in Hetzner (bootstrap only)"
}

variable "firewall_id" {
  type		= string
  description	= "Firewall ID to attach to the Headscale server"
}


// ---------- Server ----------
resource "hcloud_server" "headscale" {
  name        = "headscale"
  server_type = var.server_type
  image       = "ubuntu-24.04"
  location    = var.region
  ssh_keys    = [var.ssh_key_name]

 
  // Attach firewall at birth to ensure secure-by-default posture.
  firewall_ids = [var.firewall_id]
  
  labels = {
    role = "headscale"
    gdpr = "eu-only"
  }
}

// ---------- Outputs ----------
output "ip" {
  value		= hcloud_server.headscale.ipv4_address
  description   = "Public IPv4 for DNS (A record -> headscale.anichlabs.com)"
}
