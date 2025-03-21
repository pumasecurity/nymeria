data "aws_availability_zones" "zones_available" {
  state = "available"
}

# Note: using the keeper and lifecycle.ignore_changes results in a list that's
# shuffled once and stored in the TF state until the deployment_id changes
resource "random_shuffle" "az" {
  keepers = {
    deployment = local.deployment_id
  }

  input        = data.aws_availability_zones.zones_available.names
  result_count = 2

  lifecycle {
    ignore_changes = [input]
  }
}

resource "aws_vpc" "app" {
  cidr_block           = local.network_addresses.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${local.eks.cluster_name}-vpc"
  }
}

resource "aws_internet_gateway" "app" {
  vpc_id = aws_vpc.app.id

  tags = {
    Name = "${local.eks.cluster_name}-igw"
  }
}

resource "aws_subnet" "app_public_a" {
  vpc_id                  = aws_vpc.app.id
  cidr_block              = local.network_addresses.subnet_public_a
  availability_zone       = local.az_cyan
  map_public_ip_on_launch = false

  tags = {
    Name                     = "${local.eks.cluster_name}-public-subnet-a"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "app_public_b" {
  vpc_id                  = aws_vpc.app.id
  cidr_block              = local.network_addresses.subnet_public_b
  availability_zone       = local.az_blue
  map_public_ip_on_launch = false

  tags = {
    Name                     = "${local.eks.cluster_name}-public-subnet-b"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "app_private_a" {
  vpc_id                  = aws_vpc.app.id
  cidr_block              = local.network_addresses.subnet_private_a
  availability_zone       = local.az_cyan
  map_public_ip_on_launch = false

  tags = {
    Name                              = "${local.eks.cluster_name}-private-subnet-a"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "app_private_b" {
  vpc_id                  = aws_vpc.app.id
  cidr_block              = local.network_addresses.subnet_private_b
  availability_zone       = local.az_blue
  map_public_ip_on_launch = false

  tags = {
    Name                              = "${local.eks.cluster_name}-private-subnet-b"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_route_table" "app_public" {
  vpc_id = aws_vpc.app.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app.id
  }

  tags = {
    Name = "${local.eks.cluster_name}-public-rt"
  }
}

resource "aws_route_table_association" "app_public_a" {
  route_table_id = aws_route_table.app_public.id
  subnet_id      = aws_subnet.app_public_a.id
}

resource "aws_route_table_association" "app_public_b" {
  route_table_id = aws_route_table.app_public.id
  subnet_id      = aws_subnet.app_public_b.id
}

resource "aws_eip" "app_public_a" {
  domain = "vpc"
}

resource "aws_nat_gateway" "app_public_a" {
  allocation_id = aws_eip.app_public_a.id
  subnet_id     = aws_subnet.app_public_a.id

  tags = {
    Name = "${local.eks.cluster_name}-ngw-a"
  }
}

resource "aws_route_table" "app_private_a" {
  vpc_id = aws_vpc.app.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.app_public_a.id
  }

  tags = {
    Name = "${local.eks.cluster_name}-private-a-rt"
  }
}

resource "aws_route_table_association" "app_private_a" {
  route_table_id = aws_route_table.app_private_a.id
  subnet_id      = aws_subnet.app_private_a.id
}

# LAB COST SAVINGS: NO NEED FOR REDUNDANT NAT GWS
# resource "aws_nat_gateway" "app_public_b" {
#   allocation_id = aws_eip.app_public_b.id
#   subnet_id     = aws_subnet.app_public_b.id

#   tags = {
#     Name = "${local.eks.cluster_name}-ngw-b"
#   })
# }

# resource "aws_eip" "app_public_b" {
#   vpc = true
# }

resource "aws_route_table" "app_private_b" {
  vpc_id = aws_vpc.app.id

  route {
    cidr_block = "0.0.0.0/0"
    # LAB COST SAVINGS: NO NEED FOR REDUNDANT NAT GWS
    # nat_gateway_id = aws_nat_gateway.app_public_b.id
    nat_gateway_id = aws_nat_gateway.app_public_a.id
  }

  tags = {
    Name = "${local.eks.cluster_name}-private-b-rt"
  }
}

resource "aws_route_table_association" "app_private_b" {
  route_table_id = aws_route_table.app_private_b.id
  subnet_id      = aws_subnet.app_private_b.id
}
