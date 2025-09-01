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


output "control_plane_ip" {
  value = module.k8s_control_plane.ip
}

output "worker_ips" {
  value = module.k8s_nodes.ips
}  
