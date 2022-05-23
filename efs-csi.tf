data "aws_iam_policy_document" "efs_csi_policy" {
  statement {
    actions = [
      "elasticfilesystem:DescribeAccessPoints",
      "elasticfilesystem:DescribeFileSystems"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "elasticfilesystem:CreateAccessPoint"
    ]

    resources = [
      "*"
    ]

    # # not fully working
    # condition {
    #   test     = "StringLike"
    #   variable = "aws:RequestTag/efs.csi.aws.com/cluster"
    #   values   = ["true"]
    # }
  }

  statement {
    actions = [
      "elasticfilesystem:DeleteAccessPoint"
    ]

    resources = [
      "*"
    ]

    # # not fully working
    # condition {
    #   test     = "StringLike"
    #   variable = "aws:RequestTag/efs.csi.aws.com/cluster"
    #   values   = ["true"]
    # }
  }


}

resource "aws_iam_policy" "efs_csi" {
  path        = "/"
  description = "Nodegroup-EFSCSI-${var.name}"
  policy      = data.aws_iam_policy_document.efs_csi_policy.json
}

# add to node group IAM Role 
resource "aws_iam_role_policy_attachment" "default_node_group_AmazonEKS_EFSCSI_Policy" {
  policy_arn = aws_iam_policy.efs_csi.arn
  role       = aws_iam_role.default_node_group.name
}

