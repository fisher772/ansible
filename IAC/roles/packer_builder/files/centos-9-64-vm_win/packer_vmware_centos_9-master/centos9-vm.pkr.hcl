packer {
  required_plugins {
    vmware = {
      source  = "github.com/hashicorp/vmware"
      version = "~> 1"
    }
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
  }
}

variable "vm_os_type" {}
variable "iso_image" {}
variable "iso_image_http" {}
variable "iso_value_checksum" {}
variable "iso_value_checksum_http" {}
variable "vm_name" {}
variable "vm_name_id" {}
variable "vm_storage_size" {}
variable "ssh_user" {}
variable "ssh_pw" {}
variable "ssh_port" {}
variable "vnc_port_min" {}
variable "vnc_port_max" {}
variable "http_port_min" {}
variable "http_port_max" {}
variable "vm_mem" {}
variable "vm_cp" {}
variable "net_type" {}
variable "http_dir" {}
variable "box_path_output" {}

source "vmware-iso" "centos" {
  boot_command     = ["<wait><up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter><wait>"]
  boot_wait        = "20s"
  cpus             = var.vm_cp
  memory           = var.vm_mem
  network	         = var.net_type
  disk_size        = var.vm_storage_size
  guest_os_type    = var.vm_os_type
  headless         = true
  http_directory   = var.http_dir
  iso_checksum 	   = var.iso_value_checksum_http
  iso_urls 	       = ["${var.iso_image}","${var.iso_image_http}"]
  shutdown_command = "echo '${var.ssh_pw}'|sudo -S shutdown now"
  ssh_username     = var.ssh_user
  ssh_password     = var.ssh_pw
  ssh_port         = var.ssh_port
  ssh_wait_timeout = "20m"
  vnc_port_min	   = var.vnc_port_min
  vnc_port_max	   = var.vnc_port_max
  http_port_min    = var.http_port_min
  http_port_max    = var.http_port_max
  vm_name = join("", [var.vm_name_id, var.vm_name])
}

build {
 sources = ["source.vmware-iso.centos"]

 post-processor "vagrant" {
    compression_level = 9
    output = join("", [var.box_path_output, var.vm_name_id, var.vm_name, ".box"])
 }
}
