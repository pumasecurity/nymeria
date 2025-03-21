locals {
  network_addresses = {
    network_cidr_block              = "10.50.0.0/16"
    subnet_app_gw_public_cidr_block = "10.50.1.0/25"
    subnet_private_cidr_block       = "10.50.2.0/24"
  }

  aks = {
    cluster_name   = var.tag_owner
    services_cidr  = "10.51.0.0/17"
    dns_service_ip = "10.51.0.10"
  }

  deployment_id = random_id.deployment.hex
}

resource "random_id" "deployment" {
  byte_length = 4
}
