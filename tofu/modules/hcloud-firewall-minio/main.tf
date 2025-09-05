// tofu/modules/hcloud-firewall-minio/main.tf
// Purpose: firewall for MinIO / Backup Vault server.
// GDPR/AI Act: principle of least privilege (only SSH + VPN traffic).

resource "hcloud_firewall" "this" {
  name = "fw-minio-vault"

  // SSH only from the admin workstation / trusted IP
  rule {
    description = "Allow SSH from admin workstation"
    direction   = "in"
    protocol    = "tcp"
    port        = "22"
    source_ips  = [var.admin_cidr]
  }
  
  // MinIO S3 API (9000) via NetBird VPN only
  rule {
    description = "Allow MinIO S3 API via VPN"
    direction   = "in"
    protocol    = "tcp"
    port        = "9000"
    source_ips  = [var.vpn_cidr]
  }

  // Minio Console (9001) via NetBird VPN only
  rule {
    description = "Allow MinIO Console via VPN"
    direction   = "in"
    protocol    = "tcp"
    port        = "9001"
    source_ips  = [var.vpn_cidr]
  }

  // Outbound allowed (updates, cloud-init package, etc.)
  rule {
    description     = "Allow all outbound traffic"
    direction       = "out"
    protocol        = "tcp"
    port            = "any"
    destination_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
  description     = "Allow MinIO API from Entrypoint"
  direction       = "in"
  protocol        = "tcp"
  port            = "9000"
  source_ips      = ["10.0.1.0/24"] # adjust to Entrypoint's VPN/private IP range
  }

  rule {
    description   =  "Allow MinIO Console from Entrypoint"
    direction     = "in"
    protocol      = "tcp"
    port          = "9001"
    source_ips    = ["10.0.1.0/24"]
  }
}


