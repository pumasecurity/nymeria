locals {
  network_addresses = {
    cidr_block = "10.142.0.0/16"
    subnet_a   = "10.142.128.0/25"
    subnet_b   = "10.142.128.128/25"
  }

  # Viable availability zones
  az_blue = random_shuffle.az.result[0]
  az_cyan = random_shuffle.az.result[1]
}
