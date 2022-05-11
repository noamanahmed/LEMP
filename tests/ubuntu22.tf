resource "libvirt_volume" "ubuntu22-img" {
  name = "ubuntu22.img2"
  pool = "images" # List storage pools using virsh pool-list
  #source = "https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.img2"
  source = "/home/noaman/Downloads/ubuntu22.qcow2"
  format = "qcow2"
}




resource "libvirt_domain" "ubuntu22" {
  name   = "ubuntu-testing"
  memory = "4096"
  vcpu   = 2
  network_interface {
    network_name = "default" # List networks with virsh net-list
  }

  disk {
    volume_id = "${libvirt_volume.ubuntu22-img.id}"
  }
  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }
  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
}

# Output Server IP
# output "ip" {
#   value = "${libvirt_domain.ubuntu22.network_interface.0.addresses.0}"
# }