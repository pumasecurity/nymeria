data "aws_availability_zones" "zones_available" {
  state = "available"
}

resource "random_string" "unique_id" {
  length  = 8
  lower   = true
  numeric = true
  special = false
  upper   = false
}

# Note: using the keeper and lifecycle.ignore_changes results in a list that's
# shuffled once and stored in the TF state until the deployment_id changes
resource "random_shuffle" "az" {
  keepers = {
    deployment = random_string.unique_id.result
  }

  input        = data.aws_availability_zones.zones_available.names
  result_count = 2

  lifecycle {
    ignore_changes = [input]
  }
}

resource "aws_vpc" "cross_cloud" {
  cidr_block           = local.network_addresses.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "nymeria-cross-cloud"
    Product = "Nymeria"
  }
}

resource "aws_internet_gateway" "cross_cloud" {
  vpc_id = aws_vpc.cross_cloud.id

  tags = {
    Product = "Nymeria"
  }
}

resource "aws_subnet" "a" {
  vpc_id                  = aws_vpc.cross_cloud.id
  cidr_block              = local.network_addresses.subnet_a
  availability_zone       = local.az_cyan
  map_public_ip_on_launch = false

  tags = {
    Name    = "nymeria-cross-cloud-a"
    Product = "Nymeria"
  }
}

resource "aws_subnet" "b" {
  vpc_id                  = aws_vpc.cross_cloud.id
  cidr_block              = local.network_addresses.subnet_b
  availability_zone       = local.az_blue
  map_public_ip_on_launch = false

  tags = {
    Name    = "nymeria-cross-cloud-b"
    Product = "Nymeria"
  }
}

resource "aws_route_table" "cross_cloud" {
  vpc_id = aws_vpc.cross_cloud.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cross_cloud.id
  }

  tags = {
    Name    = "nymeria-cross-cloud"
    Product = "Nymeria"
  }
}

resource "aws_route_table_association" "cross_cloud_a" {
  route_table_id = aws_route_table.cross_cloud.id
  subnet_id      = aws_subnet.a.id
}

resource "aws_route_table_association" "cross_cloud_b" {
  route_table_id = aws_route_table.cross_cloud.id
  subnet_id      = aws_subnet.b.id
}

resource "aws_security_group" "cross_cloud" {
  name        = "nymeria-cross-cloud"
  description = "Nymeria cross-cloud security group"
  vpc_id      = aws_vpc.cross_cloud.id

  tags = {
    Name    = "nymeria-cross-cloud"
    Product = "Nymeria"
  }
}

resource "aws_security_group_rule" "cross_cloud_https_egress" {
  security_group_id = aws_security_group.cross_cloud.id
  description       = "Allow outbound HTTPS to Internet"

  type        = "egress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

data "aws_ssm_parameter" "amazon_linux_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "cross_cloud" {
  ami                         = data.aws_ssm_parameter.amazon_linux_ami.value
  instance_type               = "t3.micro"
  iam_instance_profile        = aws_iam_instance_profile.cross_cloud.name
  subnet_id                   = aws_subnet.a.id
  associate_public_ip_address = true

  user_data = templatefile("${path.root}/templates/startup.tpl",
    {
      azurerm_storage_account_name     = var.azure_storage_account_name
      azure_managed_identity_client_id = var.azure_managed_identity_client_id
      azure_tenant_id                  = var.azure_tenant_id
    }
  )

  vpc_security_group_ids = [
    aws_security_group.cross_cloud.id
  ]

  root_block_device {
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = {
    Name    = "nymeria-cross-cloud"
    Product = "Nymeria"
  }
}
