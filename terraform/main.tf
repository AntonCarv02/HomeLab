resource "proxmox_lxc" "homelab" {
  target_node     = "proxmox"
  hostname        = "homelab"
  ostemplate      = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
  password        = var.lxc_password
  ssh_public_keys = var.ssh_public_key
  unprivileged    = false
  start           = true
  onboot          = true

  features {
    nesting = true
  }

  rootfs {
    storage = "local-lvm"
    size    = "32G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "192.168.1.225/24"
    gw     = "192.168.1.1"
  }

  cores  = 6
  memory = 12288
  swap   = 2048
}