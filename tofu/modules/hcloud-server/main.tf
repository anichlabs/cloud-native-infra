// tofu/module/hcloud-server/main.tf
// Purpose: reusable Hetzner server resource, used by environments like dev/prod.
// GDPR/AI Act: no secrets hardcoded, cloud-init provided externally.

resource "hcloud_server" "this" {
  name          = var.name
  server_type   = var.server_type
  image         = var.image
  location      = var.region
  
  network {
    network_id  = var.network_id
    ip          = var.private_ip 
  }
  
  firewall_ids  = var.firewall_id != null ? [var.firewall_id] : []
  ssh_keys      = [var.ssh_key_name]

  user_data     = var.user_data

  labels = merge(
    {
      "managed_by" = "opentofu"
    },
    var.labels
  )

  delete_protection = var.delete_protection
  backups           = var.enable_backups
}


