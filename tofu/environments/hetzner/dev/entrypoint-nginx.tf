// Purpose: TLS Entrypoint with Nginx +Let's Encrypt proxy for MinIO.
// GDPR/AI Act: Terminates TLS centrally; isolates storage node from public exposure.

module "tls_entrypoint" {
  source = "../../../modules/hcloud-server"

  name        = "tls-entrypoint-dev-1"
  server_type = "cx22"
  region      = "fsn1"
  image       = "ubuntu-24.04"

  ssh_key_name = "tuxedo-ed25519"

  network_id  = module.core_network.network_id
  private_ip  = "10.0.1.30"

  delete_protection = true

  labels = {
    role = "tls-entrypoint"
    env  = "dev"
    gdpr = "no-personal-data"
  }

  firewall_id = module.hcloud_firewall_tls.firewall_id

  user_data = templatefile(
    "${path.module}/../../../modules/hcloud-server/cloud-init/entrypoint-nginx.yaml.tftpl",
    {}
  )
}

/*
  Firewall for TLS Entrypoint:
  - Allow 22/tcp from admin_cidr
  - Allow 80, 443/tcp from anywhere (for Let's Encrypt + HTTPS)
  - Allow all outbound (so proxy can reach MinIO)
*/
module "hcloud_firewall_tls" {
  source = "../../../modules/hcloud-firewall"

  name        = "fw-tls-entrypoint"
  admin_cidr  = var.admin_cidr
  cluster_cidr = "10.0.0.0/16" # same private cluster network as your servers
}

