// Module: k8s-node
// Purpose: Create one or more Kubernetes worker nodes on Hetzner Cloud.

// Create the worker nodes
resource "hcloud_server" "worker" {
  count       = var.worker_count
  name        = "w${count.index + 1}"
  server_type = var.server_type
  image       = "ubuntu-24.04"
  location    = var.region
  ssh_keys    = [var.ssh_key_name]

  network {
    network_id = var.network_id
    // no explicit ip = auto-assigned
  }
  
  firewall_ids = [var.firewall_id]
  
  labels = {
    role = "worker"
  }
}
