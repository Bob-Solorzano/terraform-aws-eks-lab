##########################################
# EKS Worker Node Security Group Output
##########################################

output "eks_node_security_group_id" {
  description = "Security group ID for EKS worker nodes."
  value       = aws_security_group.eks_nodes.id
}