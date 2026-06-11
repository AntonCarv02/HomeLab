output "vm_ip" {
  description = "IP address of the homelab VM"
  value       = proxmox_vm_qemu.homelab.default_ipv4_address
}