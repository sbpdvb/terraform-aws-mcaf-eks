# resource "aws_iam_openid_connect_provider" "default" {
#   url = aws_eks_cluster.default.identity.0.oidc.0.issuer

#   client_id_list = [
#     "sts.amazonaws.com",
#   ]

#   thumbprint_list = []
# }