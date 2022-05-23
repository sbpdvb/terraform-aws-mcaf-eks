data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  oidc_split  = split("/", aws_eks_cluster.default.identity.0.oidc.0.issuer)
  oidc_id     = element(local.oidc_split, length(local.oidc_split) - 1)
  oidc_issuer = "oidc.eks.${data.aws_region.current.name}.amazonaws.com/id/${local.oidc_id}"
  oidc_arn    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.${data.aws_region.current.name}.amazonaws.com/id/${local.oidc_id}"
}

data "aws_iam_policy_document" "ebs_csi_assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]
    principals {
      type        = "Federated"
      identifiers = [local.oidc_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
  }
}


resource "aws_iam_role" "ebs_csi" {
  name = "RoleEksCluster-EBSCSI-${var.name}"
  tags = var.tags

  assume_role_policy   = data.aws_iam_policy_document.ebs_csi_assume_role_policy.json
  permissions_boundary = var.permissions_boundary
}

# trust 
resource "aws_iam_role_policy_attachment" "ebs_csi_AmazonEKS_CSI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi.name
}


data "aws_iam_policy_document" "ebs_csi_kms_policy" {
  statement {
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]

    resources = [
      var.kms_key_arn
    ]

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }

  }

  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = [
      var.kms_key_arn
    ]
  }

}

resource "aws_iam_role_policy" "default" {
  name   = "RoleCluster-EBSCSI-${var.name}"
  role   = aws_iam_role.ebs_csi.name
  policy = data.aws_iam_policy_document.ebs_csi_kms_policy.json
}