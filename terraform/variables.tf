variable "proxmox_api_url" {
  type        = string
  description = "Proxmox API endpoint"
}

variable "proxmox_user" {
  type        = string
  description = "Proxmox user"
}

variable "proxmox_password" {
  type        = string
  sensitive   = true
  description = "Proxmox root password"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key for LXC container access"
}

variable "vm_clone" {
  type        = string
  description = "Name of the Proxmox VM template to clone"
  default     = "ubuntu-2404-cloudinit-template"
}