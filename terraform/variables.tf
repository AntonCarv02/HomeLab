variable "proxmox_api_url" {
  type        = string
  description = "Proxmox API endpoint"
}

variable "proxmox_api_token_id" {
  type        = string
  description = "Proxmox API token ID"
}

variable "proxmox_api_token_secret" {
  type        = string
  sensitive   = true
  description = "Proxmox API token secret"
}

variable "lxc_password" {
  type        = string
  sensitive   = true
  description = "Root password for the LXC container"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key for LXC container access"
}