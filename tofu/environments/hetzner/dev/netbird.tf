// File: tofu/environments/hetzner/dev/netbird.tf
// NetBird Controller Firewall + Server (NGINX TLS front)
// GDPR/AI Act: EU-hosted (Hetzner DE). Keep secrets out of state.

resource "hcloud_firewall" "netbird" {
  name = "fw-netbird-controller"

  // Inbound
  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "22"
    source_ips  = [var.admin_cidr]
    description = "SSH (admin only)"
  }

  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "80"
    source_ips  = ["0.0.0.0/0", "::/0"]
    description = "HTTP"
  }

  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "443"
    source_ips  = ["0.0.0.0/0", "::/0"]
    description = "HTTPS"
  }

  // NetBird components (HTTP/2+gRPC sit behind NGINX)
  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "33073"
    source_ips  = ["0.0.0.0/0", "::/0"]
    description = "NetBird Management TCP"
  }

  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "10000"
    source_ips  = ["0.0.0.0/0", "::/0"]
    description = "NetBird Signal TCP"
  }

  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "33080"
    source_ips  = ["0.0.0.0/0", "::/0"]
    description = "NetBird Relay TCP (optional)"
  }

  rule {
    direction   = "in"
    protocol    = "udp"
    port        = "3478"
    source_ips  = ["0.0.0.0/0", "::/0"]
    description = "STUN/TURN 3478/udp"
  }

  rule {
    direction   = "in"
    protocol    = "udp"
    port        = "49152-65535"
    source_ips  = ["0.0.0.0/0", "::/0"]
    description = "TURN relay high UDP"
  }

  // Intra-VPC diagnostics (optional)
  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "1-65535"
    source_ips  = ["10.0.0.0/24"]
    description = "intra-VPC TCP"
  }

  rule {
    direction   = "in"
    protocol    = "udp"
    port        = "1-65535"
    source_ips  = ["10.0.0.0/24"]
    description = "intra-VPC UDP"
  }

  rule {
    direction   = "in"
    protocol    = "icmp"
    source_ips  = ["10.0.0.0/24"]
    description = "intra-VPC ICMP"
  }

  // Outbound allow-all (updates, ACME, IdP, registries)
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

module "netbird_controller" {
  source      = "../../../modules/hcloud-server"
  name        = "netbird-controller-dev-1"
  server_type = "cx22"
  region      = "fsn1"
  image       = "ubuntu-24.04"

  ssh_key_name = "tuxedo-ed25519"
  network_id   = module.core_network.network_id
  private_ip   = "10.0.0.10"
  firewall_id  = hcloud_firewall.netbird.id

  user_data = templatefile(
    "${path.module}/../../../modules/hcloud-server/cloud-init/netbird-nginx.yaml.tftpl",
    {
      netbird_domain     = "vpn.dev.anichlabs.com"
      letsencrypt_email  = "chris@anichlabs.com"
      turn_udp_min_port  = 49152
      turn_udp_max_port  = 65535
      oidc_client_id     = ""
      oidc_client_secret = ""
      oidc_issuer_url    = ""
    }
  )

  labels = {
    role   = "netbird-controller"
    env    = "dev"
    gdpr   = "eu-hosted"
    ai_act = "compliant"
  }
}
