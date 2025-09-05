terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.0.0"
    }
  }
}

resource "hcloud_network" "main" {
  name     = var.network_name
  ip_range = var.network_cidr
}

# Add at least one subnet so servers can actually join the network
resource "hcloud_network_subnet" "main" {
  type         = "cloud"
  network_id   = hcloud_network.main.id
  network_zone = "eu-central"   # valid for fsn1 and nbg1
  ip_range     = "10.0.0.0/24"  # carve first /24 from your /16
}

# Add a second subnet for 10.0.1.0/24 (for Entrypoint/MinIO)
resource "hcloud_network_subnet" "dmz" {
  network_id   = hcloud_network.main.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}
