// tofu/environments/hetzner/dev/volume-minio.tf
// Purpose: Persistent data volume for MinIO (dev).
// GDPR/AI Act: Separates data from the instance, supports lifecycle control and secure erase.

resource "hcloud_volume" "minio_data" {
  name              = "minio-data-dev"
  size              = var.minio_volume_size # GiB.
  format            = "ext4"                # Let Hetzner prep the FS; Explicitly mount it later.
  location          = "fsn1"                # Location of the server.
  
  labels = {
    role = "minio-data"
    env  = "dev"
    gdpr = "no-personal-data"
  }
}

// Attach the volume to the MinIO server.
// Do NOT automount: Do not mount to /var/minio in cloud-init.

resource "hcloud_volume_attachment" "minio_data" {
  volume_id     = hcloud_volume.minio_data.id
  server_id     = module.minio_vault.id
  automount     = false
}