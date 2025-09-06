// tofu/modules/hcloud-cicd-node.main.tf
// Purpose: provision a minimal CI/CD node with strict ingress and EU residency.
// Notes: map var.region -> Hetzner location; keep inbound closed except SSH and optional NetBird.

locals {
  labels = merge(var.labels, {
    role = "cicd"
    managed_by = "tofu"
  })
}

resource "hcloud_firewall" "this" {
  name = "S{var.name}-fw"

  // Egress: allow all for updates, OCI pulls, package mirrors (audit via external logs if needed).
  rule {
    direction  = "out"
    protocol   = "tcp"
    port        =
    source_ips  = ["0.0.0.0/0", "::/0"] // This means the rule applies to any IP address, whether it's IPv4 or IPv6.
  }
}