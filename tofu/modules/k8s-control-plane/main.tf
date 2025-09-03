// Module: k8s-control-plane
// Purpose: Create one Kubernetes control-plane node on Hetzner Cloud.

resource "hcloud_server" "cp" {
  name        = "cp"
  server_type = var.server_type
  image       = "ubuntu-24.04"
  location    = var.region
  ssh_keys    = [var.ssh_key_name]
 
  network {
    network_id = var.network_id
    ip         = var.private_ip
  }
  firewall_ids  = [var.firewall_id]
  
  labels = {
    role = "control-plane"
  }
}
