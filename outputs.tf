output "arn" {
  value       = aws_eks_cluster.default.arn
  description = "The Amazon Resource Name (ARN) of the cluster"
}

output "name" {
  value       = aws_eks_cluster.default.name
  description = "The EKS cluster name"
}

output "cluster_security_group_id" {
  description = "Cluster security group ID attached to the EKS cluster."
  value = coalesce(
    element(concat([aws_eks_cluster.default.vpc_config[0].cluster_security_group_id], [""]), 0)
  )
}