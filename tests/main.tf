terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      # version = "0.6.14"
    }
  }
}


provider "libvirt" {
  ## Configuration options
  uri = "qemu:///system"
  #alias = "server2"
  #uri   = "qemu+ssh://root@192.168.100.10/system"
}
