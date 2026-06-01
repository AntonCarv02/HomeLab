output "lxc_ip" {
  description = "IP address of the homelab LXC container"
  value       = proxmox_lxc.homelab.network[0].ip
}