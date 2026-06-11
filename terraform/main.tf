resource "proxmox_vm_qemu" "homelab" {
  target_node = "proxmox"
  name        = "homelab"
  vmid        = 100
  clone       = var.vm_clone
  start_at_node_boot      = true
  os_type     = "cloud-init"

  cpu {
  cores = 6
}
  memory  = 12288

  disk {
    slot    = "scsi0"
    size    = "32G"
    storage = "local-lvm"
    type    = "disk"
  }
  disk {
  slot    = "ide2"
  storage = "local-lvm"
  type    = "cloudinit"
}
  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  ipconfig0  = "ip=192.168.1.225/24,gw=192.168.1.1"
  sshkeys    = var.ssh_public_key
  ciuser     = "ubuntu"
  scsihw = "virtio-scsi-pci"
  
}