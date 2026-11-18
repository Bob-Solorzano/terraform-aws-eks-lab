
##########################################
# General Configuration
##########################################

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
}

##########################################
# Network Configuration
##########################################

variable "private_subnet_ids" {
  description = "Private subnet IDs used by the EKS cluster and worker nodes."
  type        = list(string)
}

##########################################
# Worker Node Configuration
##########################################

variable "node_instance_type" {
  description = "EC2 instance type for EKS worker nodes."
  type        = string
}

variable "node_desired_size" {
  description = "Desired number of worker nodes."
  type        = number
}

variable "node_min_size" {
  description = "Minimum number of worker nodes."
  type        = number
}

variable "node_max_size" {
  description = "Maximum number of worker nodes."
  type        = number
}

##########################################
# API Endpoint Access
##########################################

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDR ranges allowed to access the public EKS API endpoint."
  type        = list(string)
}