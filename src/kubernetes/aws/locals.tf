locals {
  network_addresses = {
    vpc_cidr_block   = "10.60.0.0/16"
    subnet_private_a = "10.60.128.0/20"
    subnet_private_b = "10.60.144.0/20"
    subnet_public_a  = "10.60.2.0/25"
    subnet_public_b  = "10.60.2.128/25"
  }

  # Viable availability zones
  az_blue = random_shuffle.az.result[0]
  az_cyan = random_shuffle.az.result[1]

  eks = {
    cluster_name    = var.tag_owner
    host_mount_path = "/opt/data/${var.tag_owner}"
  }

  deployment_id = random_id.deployment_id.hex
}

resource "random_id" "deployment_id" {
  byte_length = 4
}
