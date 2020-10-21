output "arn" {
  value       = aws_eks_cluster.default.arn
  description = "The Amazon Resource Name (ARN) of the cluster"
}

output "name" {
  value       = aws_eks_cluster.default.name
  description = "The EKS cluster name"
}
