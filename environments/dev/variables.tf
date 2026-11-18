
########################################
# Environment Config
########################################

variable "environment" {
  type = string
}

########################################
# Network Config
########################################

variable "availability_zones" {
  description = "Availability zones used by subnets within the VPC."
  type        = list(string)
}

variable "vpc_name" {
  description = "Name of the VPC."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block used to create the VPC."
  type        = string
}

variable "internet_gw_name" {
  description = "Name of the Internet Gateway."
  type        = string
}

# Public subnets
variable "public_subnet_cidrs" {
  description = "CIDR blocks used to create public subnets within the VPC."
  type        = list(string)
}

# Private subnets
variable "private_subnet_cidrs" {
  description = "CIDR blocks used to create private subnets within the VPC."
  type        = list(string)
}

##########################################
# EKS Cluster Configuration
##########################################

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDR ranges allowed to access the public EKS API endpoint."
  type        = list(string)
}

##########################################
# EKS Worker Node Configuration
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
