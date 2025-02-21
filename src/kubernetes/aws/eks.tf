# https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster
resource "aws_eks_cluster" "nymeria" {
  name     = "${local.eks.cluster_name}-eks-cluster"
  role_arn = aws_iam_role.eks.arn

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  vpc_config {
    subnet_ids = [
      aws_subnet.app_private_a.id,
      aws_subnet.app_private_b.id
    ]
  }

  kubernetes_network_config {
    ip_family         = "ipv4"
    service_ipv4_cidr = "172.30.0.0/16"
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  tags = {
    Product = local.eks.cluster_name
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster,
    aws_iam_role_policy_attachment.eks_cluster_vpc
  ]
}

resource "aws_eks_node_group" "nymeria" {
  cluster_name         = aws_eks_cluster.nymeria.name
  node_group_name      = "${local.eks.cluster_name}-eks-node-group"
  node_role_arn        = aws_iam_role.eks_node.arn
  instance_types       = [var.eks_instance_type]
  force_update_version = true

  subnet_ids = [
    aws_subnet.app_private_a.id,
    aws_subnet.app_private_b.id
  ]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  launch_template {
    id      = aws_launch_template.nymeria.id
    version = aws_launch_template.nymeria.latest_version
  }

  tags = {
    Product = local.eks.cluster_name
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_worker,
    aws_iam_role_policy_attachment.eks_node_cni,
    aws_iam_role_policy_attachment.eks_node_container,
  ]
}

# launch template for EKS nodes
resource "aws_launch_template" "nymeria" {
  name = "${local.eks.cluster_name}-eks-node-template"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 50
    }
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Product = local.eks.cluster_name,
      Name    = "${local.eks.cluster_name}-eks-node"
    }
  }
}

resource "aws_eks_addon" "nymeria_coredns" {
  cluster_name = aws_eks_cluster.nymeria.name
  addon_name   = "coredns"

  tags = {
    Product = local.eks.cluster_name
  }
}

resource "aws_eks_addon" "nymeria_kube_proxy" {
  cluster_name = aws_eks_cluster.nymeria.name
  addon_name   = "kube-proxy"

  tags = {
    Product = local.eks.cluster_name
  }
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.nymeria.name
  addon_name   = "vpc-cni"

  tags = {
    Product = local.eks.cluster_name
  }
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = aws_eks_cluster.nymeria.name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.eks_ebs_csi.arn

  tags = {
    Product = local.eks.cluster_name
  }
}
