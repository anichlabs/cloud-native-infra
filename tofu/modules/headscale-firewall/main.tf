// File: tofu/modules/headscale-firewall/main.tf
// Purpose: Firewall rules for the Headscale server (no SSH exposed).

variable "name" {
  type		= string
  description	= "Firewall name"
  default	= "headscale-firewall"
}


resource "hcloud_firewall" "this" {
  name = var.name
  
  // --- Inbound: ACME challenge (HTTP-01)
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "80"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  // --- Inbound: Headscale control plane via HTTPS.
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "443"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  // --- Outbound: allow updates, DNS, image pulls, etc.
  rule {
    direction		= "out"
    protocol		= "tcp"
    port		= "any"
    destination_ips	= ["0.0.0.0/0", "::/0"]
  }
  rule {
    direction		= "out"
    protocol		= "udp"
    port		= "any"
    destination_ips	= ["0.0.0.0/0", "::/0"]
  }
  rule {
    direction		= "out"
    protocol		= "icmp"
    destination_ips	= ["0.0.0.0/0", "::/0"]
  }
}

output "firewall_id" {
  description = "Firewall ID to attach to the Headscale server."
  value       = hcloud_firewall.this.id
}
