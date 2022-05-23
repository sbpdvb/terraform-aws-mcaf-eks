resource "aws_cloudwatch_log_group" "default" {
  name              = "/aws/eks/${var.name}/cluster"
  retention_in_days = var.log_retention
}

resource "aws_eks_cluster" "default" {
  name                      = var.name
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  role_arn                  = aws_iam_role.default.arn
  tags                      = var.tags

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs

  }

  encryption_config {
    provider {
      key_arn =var.kms_key_arn
    }
    resources = ["secrets"]
  }

  depends_on = [
    aws_cloudwatch_log_group.default,
    aws_iam_role_policy_attachment.default_AmazonEKSClusterPolicy,
  ]
}

resource "aws_launch_template" "default" {
  name = "${var.name}-default-launch-template"
  monitoring {
    enabled = true
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = var.disk_size
      encrypted   = true
      volume_type = "gp3"
      kms_key_id  = var.kms_key_arn

    }
  }

  user_data = var.user_data
}

resource "aws_eks_node_group" "default" {
  count           = var.create_node_group == false ? 0 : 1
  cluster_name    = aws_eks_cluster.default.name
  instance_types  = var.instance_types
  node_group_name = "default_node"
  node_role_arn   = aws_iam_role.default_node_group.arn
  subnet_ids      = var.subnet_ids


  scaling_config {
    desired_size = var.scaling_config.desired_size
    max_size     = var.scaling_config.max_size
    min_size     = var.scaling_config.min_size
  }

  disk_size = var.disk_size


  dynamic "launch_template" {
    for_each = var.enable_launch_template ? [1] : []
    content {
      id      = aws_launch_template.default.id
      version = aws_launch_template.default.latest_version
    }
  }


  depends_on = [
    aws_iam_role_policy_attachment.default_node_group_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.default_node_group_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.default_node_group_AmazonEKSWorkerNodePolicy,
  ]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  tags = var.tags
}

resource "aws_iam_role" "default" {
  name = "RoleEksCluster-${var.name}"
  tags = var.tags

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [{
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "eks.amazonaws.com"
        },
        "Effect" : "Allow"
      }]
    }
  )

  permissions_boundary = var.permissions_boundary
}

resource "aws_iam_role" "default_node_group" {
  name = "RoleEksClusterNodeGroup-${var.name}"
  tags = var.tags

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })

  permissions_boundary = var.permissions_boundary
}

resource "aws_iam_role_policy_attachment" "default_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.default.name
}

resource "aws_iam_role_policy_attachment" "default_node_group_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.default_node_group.name
}

resource "aws_iam_role_policy_attachment" "default_node_group_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.default_node_group.name
}

resource "aws_iam_role_policy_attachment" "default_node_group_AmazonEKS_EBSCSI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.default_node_group.name
}

resource "aws_iam_role_policy_attachment" "default_node_group_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.default_node_group.name
}

resource "aws_iam_role_policy_attachment" "default_node_group_SSMCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.default_node_group.name
}


data "aws_iam_policy_document" "default_node_group_ebs_csi_kms_policy" {
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

resource "aws_iam_role_policy" "default_node_group_ebs_csi_kms" {
  name   = "Nodegroup-EBSCSI-${var.name}"
  role   = aws_iam_role.default_node_group.name
  policy = data.aws_iam_policy_document.default_node_group_ebs_csi_kms_policy.json
}


resource "aws_eks_addon" "addon" {
  for_each      = var.addons
  cluster_name  = aws_eks_cluster.default.name
  addon_name    = each.key
  addon_version = each.value
}



