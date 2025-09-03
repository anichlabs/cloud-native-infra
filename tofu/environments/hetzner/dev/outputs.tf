output "network_id" {
  description = "Hetzner Cloud network ID"
  value       = module.core_network.network_id
}

output "network_name" {
  description = "Hetzner Cloud network name"
  value       = module.core_network.network_name
}

output "network_ip_range" {
  description = "Hetzner Cloud network IP range"
  value       = module.core_network.network_ip_range
}

output "control_plane_ip" {
  value = module.k8s_control_plane.ip
}

output "worker_ips" {
  value = module.k8s_nodes.ips
}  
