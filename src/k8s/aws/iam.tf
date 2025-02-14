data "aws_iam_policy_document" "eks_assume_role" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
    effect  = "Allow"
  }
}

resource "aws_iam_role" "eks" {
  name               = "${local.eks.cluster_name}-role-${local.deployment_id}"
  path               = "/"
  description        = "IAM role for ${local.eks.cluster_name} EKS cluster"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role.json

  tags = {
    Product = local.eks.cluster_name
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  role       = aws_iam_role.eks.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_vpc" {
  role       = aws_iam_role.eks.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
    effect  = "Allow"
  }
}

resource "aws_iam_role" "eks_node" {
  name               = "${local.eks.cluster_name}-node-role-${local.deployment_id}"
  path               = "/"
  description        = "IAM role for ${local.eks.cluster_name} EKS cluster nodes"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Product = local.eks.cluster_name
  }
}

resource "aws_iam_role_policy_attachment" "eks_node_worker" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_node_cni" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_node_container" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "eks_node_cloudwatch" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_node_ssm" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Cluster OIDC Provider for service account role assumption
# https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html
data "tls_certificate" "eks" {
  url = aws_eks_cluster.nymeria.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  url = aws_eks_cluster.nymeria.identity[0].oidc[0].issuer

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [
    data.tls_certificate.eks.certificates[0].sha1_fingerprint,
  ]

  tags = {
    Product = local.eks.cluster_name
  }
}

# Cluster AWS EBS CSI Driver
# https://docs.aws.amazon.com/eks/latest/userguide/csi-iam-role.html
data "aws_iam_policy_document" "eks_ebs_csi_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
  }
}

resource "aws_iam_role" "eks_ebs_csi" {
  name               = "${local.eks.cluster_name}-ebs-csi-role-${local.deployment_id}"
  path               = "/"
  description        = "IAM role for ${local.eks.cluster_name} EKS cluster EBS CSI"
  assume_role_policy = data.aws_iam_policy_document.eks_ebs_csi_assume_role.json

  tags = {
    Product = local.eks.cluster_name
  }
}

resource "aws_iam_role_policy_attachment" "eks_ebs_csi_controller" {
  role       = aws_iam_role.eks_ebs_csi.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# AUDIT LOG IAM RESOURCES
# data "aws_iam_policy_document" "audit_log_assume_role" {
#   statement {
#     principals {
#       type = "Service"
#       identifiers = [
#         "cloudtrail.amazonaws.com",
#         "vpc-flow-logs.amazonaws.com",
#         "delivery.logs.amazonaws.com",
#       ]
#     }

#     actions = ["sts:AssumeRole"]
#     effect  = "Allow"
#   }
# }

# resource "aws_iam_role" "audit_log" {
#   name               = "${local.eks.cluster_name}-audit-logs-role-${local.deployment_id}"
#   path               = "/"
#   description        = "IAM role for CloudWatch audit logging"
#   assume_role_policy = data.aws_iam_policy_document.audit_log_assume_role.json

#   tags = {
#     Product = "security"
#   }
# }

# data "aws_iam_policy_document" "audit_log_policy" {
#   statement {
#     sid    = "AllowCloudWatchLogging"
#     effect = "Allow"
#     actions = [
#       "logs:CreateLogGroup",
#       "logs:CreateLogStream",
#       "logs:DescribeLogGroups",
#       "logs:DescribeLogStreams",
#       "logs:PutLogEvents",
#       "logs:GetLogEvents",
#       "logs:FilterLogEvents",
#     ]
#     resources = [
#       "${aws_cloudwatch_log_group.cloudtrail.arn}:*",
#       "${aws_cloudwatch_log_group.flow_logs.arn}:*",
#     ]
#   }
# }

# resource "aws_iam_policy" "audit_log" {
#   name        = "${local.eks.cluster_name}-audit-logs-policy-${local.deployment_id}"
#   path        = "/"
#   description = "IAM policy for CloudWatch audit logging"
#   policy      = data.aws_iam_policy_document.audit_log_policy.json

#   tags = {
#     Product = "security"
#   }
# }

# resource "aws_iam_role_policy_attachment" "audit_log" {
#   role       = aws_iam_role.audit_log.name
#   policy_arn = aws_iam_policy.audit_log.arn
# }

# NODE APP PERMISSIONS
# data "aws_iam_policy_document" "nymeria_pod" {
#   statement {
#     sid    = "AllowS3ListAllAccess"
#     effect = "Allow"
#     actions = [
#       "s3:ListAllMyBuckets",
#     ]
#     resources = ["*"]
#   }

#   statement {
#     sid    = "AllowS3ListAccess"
#     effect = "Allow"
#     actions = [
#       "s3:ListBucket",
#     ]
#     resources = [
#       aws_s3_bucket.nymeria.arn
#     ]
#   }

#   statement {
#     sid    = "AllowS3DataAccess"
#     effect = "Allow"
#     actions = [
#       "s3:GetObject",
#       "s3:GetObjectAttributes",
#       "s3:GetObjectTagging",
#     ]
#     resources = [
#       "${aws_s3_bucket.nymeria.arn}/*"
#     ]
#   }
# }

# resource "aws_iam_policy" "nymeria_pod" {
#   name        = "${local.eks.cluster_name}-api-pod-policy-${local.deployment_id}"
#   path        = "/"
#   description = "IAM policy for ${local.eks.cluster_name} pods running in EKS"
#   policy      = data.aws_iam_policy_document.nymeria_pod.json

#   tags = {
#     Product = local.eks.cluster_name
#   }
# }

# resource "aws_iam_role_policy_attachment" "nymeria_pod" {
#   role       = aws_iam_role.eks_node.name
#   policy_arn = aws_iam_policy.nymeria_pod.arn
# }

# resource "aws_iam_user" "maverick" {
#   name = "kubeace-maverick-${local.deployment_id}"
#   path = "/"

#   tags = {
#     Product = local.eks.cluster_name
#   }
# }
