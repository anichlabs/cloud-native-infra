terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.0.0"
    }
  }
}

provider "hcloud" {
  # Token is read from HCLOUD_TOKEN environment variable
}

module "core_network" {
  source       = "../../../modules/core-network"
  network_name = "cloud-native-network"
  network_cidr = "10.0.0.0/16"
}

module "hcloud_firewall" {
  source       = "../../../modules/hcloud-firewall"
  admin_cidr   = var.admin_cidr
  cluster_cidr = "10.0.0.0/16"
}  

module "k8s_control_plane" {
  source      = "../../../modules/k8s-control-plane"
  region      = "fsn1"
  server_type = "cpx21"
  ssh_key_name = "tuxedo-ed25519"
  network_id   = module.core_network.network_id
  private_ip   = "10.0.0.10"
  firewall_id  = module.hcloud_firewall.firewall_id
}

module "k8s_nodes" {
  source        = "../../../modules/k8s-node"
  region        = "fsn1"
  server_type   = "cpx21"
  ssh_key_name  = "tuxedo-ed25519"
  network_id    = module.core_network.network_id
  worker_count  = 2
  firewall_id   = module.hcloud_firewall.firewall_id
}


// MinIO / Backup Vault server (CX22)
// Purpose: encrypted object storage for Terraform state, configs, ML checkpoints.
// Notes: GDPR/AI Act compliance; no personal data, only infra/state artifacts.

module "hcloud_firewall_minio" {
  source     = "../../../modules/hcloud-firewall-minio"
  admin_cidr = var.admin_cidr
  vpn_cidr   = var.vpn_cidr
}

module "minio_vault" {
  source = "../../../modules/hcloud-server"

  name         = "minio-vault-dev-1"
  server_type  = "cx22"
  image        = "ubuntu-24.04"
  region       = "fsn1"

  network_id   = module.core_network.network_id
  private_ip   = "10.0.1.20" // Choose next free IP in the network range.
  firewall_id  = module.hcloud_firewall_minio.firewall_id
  ssh_key_name = "tuxedo-ed25519"

  labels = {
    role    = "minio-backup-vault"
    env     = "dev"
    gdpr    = "no-personal-data"
    ai_act  = "compliant"
  }

  user_data = templatefile(
  "${path.module}/../../../modules/hcloud-server/cloud-init/minio.yaml.tftpl",
  {
    minio_root_user     = var.minio_root_user
    minio_root_password = var.minio_root_password
  }
 )
}
