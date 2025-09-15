// tofu/modules/hcloud-cicd-node/main.tf
// Purpose: provision a minimal CI/CD node with strict ingress and EU residency.
// Notes: pass var.region into the required 'location' field; keep inbound closed except SSH and optional NetBird.

locals {
  labels = merge(var.labels, {
    role       = "cicd"
    managed_by = "tofu"
  })
}

resource "hcloud_firewall" "this" {
  name = "${var.name}-fw"

  // Egress: allow all for updates, OCI pulls, package mirrors (audit externally if needed).
  rule {
    direction  = "out"
    protocol   = "tcp"
    port       = "1-65535"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
  rule {
    direction  = "out"
    protocol   = "udp"
    port       = "1-65535"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
  rule {
    direction  = "out"
    protocol   = "icmp"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  // Ingress: SSH only from declared admin CIDRs (empty list keeps SSH closed).
  dynamic "rule" {
    for_each = var.admin_cidrs
    content {
      direction   = "in"
      protocol    = "tcp"
      port        = "22"
      source_ips  = [rule.value]
      description = "SSH from admin CIDR"
    }
  }

  // Ingress (optional later): NetBird WireGuard (UDP/51820). Enable only when ready.
  dynamic "rule" {
    for_each = var.enable_netbird ? [1] : []
    content {
      direction   = "in"
      protocol    = "udp"
      port        = "51820"
      source_ips  = ["0.0.0.0/0", "::/0"]
      description = "NetBird (enable only when control plane is configured)"
    }
  }
}

resource "hcloud_server" "this" {
  name        = var.name
  image       = var.image
  server_type = var.server_type
  location    = var.region              // Map your 'region' variable to the required 'location' argument.
  labels      = local.labels
  ssh_keys    = var.ssh_key_ids

  backups           = var.enable_backups
  delete_protection = var.delete_protection

  // Public networking toggles: use *_enabled booleans (not Primary IP IDs).
  public_net {
    ipv4_enabled = var.enable_public_ipv4
    ipv6_enabled = var.enable_ipv6
  }

  // Cloud-init: render template with selected runtime and user (no secrets here).
  user_data = templatefile("${path.module}/cloud-init/cicd.yaml.tmpl", {
    container_runtime = var.container_runtime
    user              = var.user
  })

  // Attach firewall.
  firewall_ids = [hcloud_firewall.this.id]
}

resource "hcloud_server_network" "this" {
  server_id  = hcloud_server.this.id
  network_id = var.network_id

  // Bind a static private IP if provided; otherwise omit for automatic allocation.
  ip = var.private_ip
}