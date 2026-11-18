##########################################
# AWS Load Balancer Controller Variables
##########################################

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the EKS OIDC identity provider"
  type        = string
}

variable "oidc_issuer_url" {
  description = "URL of the EKS OIDC issuer"
  type        = string
}