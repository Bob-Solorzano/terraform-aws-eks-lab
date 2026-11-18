
##########################################
# EKS Cluster IAM Role Output
##########################################

output "eks_cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role."
  value       = aws_iam_role.eks_cluster.arn
}

##########################################
# EKS Worker Node IAM Role Output
##########################################

output "eks_node_role_arn" {
  description = "ARN of the EKS worker node IAM role."
  value       = aws_iam_role.eks_nodes.arn
}

##########################################
# EKS Managed Node Group Outputs
##########################################

output "eks_node_group_name" {
  description = "Name of the EKS managed node group."
  value       = aws_eks_node_group.this.node_group_name
}

output "eks_node_group_status" {
  description = "Status of the EKS managed node group."
  value       = aws_eks_node_group.this.status
}

##########################################
# EKS OIDC Identity Provider Outputs
##########################################

output "oidc_provider_arn" {
  description = "ARN of the EKS OIDC identity provider"
  value       = aws_iam_openid_connect_provider.eks.arn
}

##########################################
# EKS OIDC Issuer Outputs
##########################################

output "oidc_issuer_url" {
  description = "URL of the EKS OIDC issuer"
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}