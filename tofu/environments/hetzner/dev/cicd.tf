// File: tofu/environments/hetzner/dev/cicd.tf
// Purpose: CI/CD node (Podman by default), minimal ingress, EU residency.
// Notes: place in DMZ 10.0.1.0/24; keep secrets out of state; no services started by cloud-init.

module "cicd" {
  source = "../../../modules/hcloud-cicd-node"

  # Identity
  name        = "cicd-dev-1"
  server_type = "cx22"
  image       = "ubuntu-24.04"
  region      = "fsn1"                          // Map to Hetzner 'location'

  # Access
  ssh_key_ids = ["tuxedo-ed25519"]              // Same key used elsewhere in your env
  admin_cidrs = [var.admin_cidr]                // Restrict SSH to your admin workstation

  # Networking (DMZ)
  network_id  = module.core_network.network_id
  private_ip  = "10.0.1.10"                     // Reserve early slot in DMZ; adjust if taken
  enable_public_ipv4 = true                     // Needed for package updates/OCI pulls
  enable_ipv6        = false

  # Runtime toggle
  container_runtime = "podman"                  // Prefer rootless; flip to "docker" if ever required
  enable_netbird    = false                     // Keep WG closed until controller exists

  # Compliance labelling (avoid PII)
  labels = {
    env        = "dev"
    role       = "cicd"
    gdpr       = "eu-hosted"
    ai_act     = "compliant"
    managed_by = "tofu"
  }

  # Safety
  delete_protection = true
  enable_backups    = false
}

# Optional: surface key outputs for convenience
output "cicd_private_ipv4" { value = module.cicd.private_ip }
output "cicd_public_ipv4"  { value = module.cicd.public_ipv4 }
output "cicd_labels"       { value = module.cicd.labels }

