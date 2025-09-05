# ─────────────────────────────────────────────────────────────
# File: tofu/environments/hetzner/dev/monitoring.tf
# Purpose: Monitoring & Observability VM (Prometheus, Grafana, Loki) behind NGINX TLS
# Notes (GDPR/AI Act): EU-hosted; no secrets in state; restrict SSH; TLS via Let's Encrypt.
# Networking: place in 10.0.1.0/24 (DMZ) at 10.0.1.40. Adjust if already taken.
# ─────────────────────────────────────────────────────────────

resource "hcloud_firewall" "monitoring" {
  name = "fw-monitoring"

  # Inbound: SSH from admin only
  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "22"
    source_ips  = [var.admin_cidr]
    description = "SSH (admin only)"
  }

  # Inbound: HTTP/HTTPS for ACME + access (can later restrict to VPN or Entrypoint)
  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "80"
    source_ips  = ["0.0.0.0/0", "::/0"]
    description = "HTTP (ACME)"
  }

  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "443"
    source_ips  = ["0.0.0.0/0", "::/0"]
    description = "HTTPS"
  }

  # Optional: allow direct service ports from VPN only (Grafana / Prometheus / Loki)
  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "3000"
    source_ips  = [var.vpn_cidr]
    description = "Grafana via VPN"
  }

  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "9090"
    source_ips  = [var.vpn_cidr]
    description = "Prometheus via VPN"
  }

  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "3100"
    source_ips  = [var.vpn_cidr]
    description = "Loki via VPN"
  }

  # Outbound allow-all (updates, ACME, container registries)
  rule {
    direction       = "out"
    protocol        = "tcp"
    port            = "any"
    destination_ips = ["0.0.0.0/0", "::/0"]
  }
  rule {
    direction       = "out"
    protocol        = "udp"
    port            = "any"
    destination_ips = ["0.0.0.0/0", "::/0"]
  }
  rule {
    direction       = "out"
    protocol        = "icmp"
    destination_ips = ["0.0.0.0/0", "::/0"]
  }
}

module "monitoring" {
  source      = "../../../modules/hcloud-server"

  name        = "monitoring-dev-1"
  server_type = "cx22"
  region      = "fsn1"
  image       = "ubuntu-24.04"

  ssh_key_name = "tuxedo-ed25519"

  network_id  = module.core_network.network_id
  private_ip  = "10.0.1.40"
  firewall_id = hcloud_firewall.monitoring.id

  user_data = templatefile(
    "${path.module}/../../../modules/hcloud-server/cloud-init/monitoring-nginx.yaml.tftpl",
    {
      monitoring_domain = "monitoring.dev.anichlabs.com"
      letsencrypt_email = "admin@anichlabs.com"
    }
  )

  labels = {
    role   = "monitoring"
    env    = "dev"
    gdpr   = "eu-hosted"
    ai_act = "compliant"
  }
}
