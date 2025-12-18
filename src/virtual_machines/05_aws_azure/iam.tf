# enables account level web identity federation
resource "aws_iam_outbound_web_identity_federation" "this" {}

# instance role policy resources
data "aws_iam_policy_document" "cross_cloud" {
  statement {
    sid    = "AllowTokenVending"
    effect = "Allow"
    actions = [
      "sts:GetWebIdentityToken",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "cross_cloud" {
  name        = "nymeria-cross-cloud-token-${random_string.unique_id.result}"
  path        = "/"
  description = "IAM policy for Nymeria VM"
  policy      = data.aws_iam_policy_document.cross_cloud.json

  tags = {
    Product = "Nymeria"
  }
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

resource "aws_iam_role" "cross_cloud" {
  name               = "nymeria-cross-cloud-${random_string.unique_id.result}"
  path               = "/"
  description        = "IAM role for Nymeria VM"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Product = "Nymeria"
  }
}

resource "aws_iam_role_policy_attachment" "cross_cloud" {
  role       = aws_iam_role.cross_cloud.name
  policy_arn = aws_iam_policy.cross_cloud.arn
}

resource "aws_iam_role_policy_attachment" "cross_cloud_ssm" {
  role       = aws_iam_role.cross_cloud.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "cross_cloud" {
  name = "nymeria-cross-cloud-profile-${random_string.unique_id.result}"
  role = aws_iam_role.cross_cloud.name
}
