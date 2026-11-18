
##########################################
# AWS Provider
##########################################

provider "aws" {
  region = "us-west-2"

  default_tags {
    tags = {
      Project     = "terraform-aws-eks-lab"
      Environment = "dev"
      Owner       = "bob"
      ManagedBy   = "terraform"
      CostCenter  = "lab"
    }
  }
}

##########################################
# VPC Module
##########################################

module "vpc" {
  source = "../../modules/vpc"

  # Global Variables
  environment        = var.environment
  availability_zones = var.availability_zones

  # VPC Variables
  vpc_name         = var.vpc_name
  vpc_cidr         = var.vpc_cidr
  internet_gw_name = var.internet_gw_name

  # Subnet Variables
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

##########################################
# Security Module
##########################################

module "security" {
  source = "../../modules/security"

  environment = var.environment
  vpc_id      = module.vpc.vpc_id
}

##########################################
# EKS Module
##########################################

module "eks" {
  source = "../../modules/eks"

  # General Configuration
  environment        = var.environment
  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version

  # Network Configuration
  private_subnet_ids = module.vpc.private_subnet_ids

  # API Endpoint Access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  # Worker Node Configuration
  node_instance_type = var.node_instance_type
  node_desired_size  = var.node_desired_size
  node_min_size      = var.node_min_size
  node_max_size      = var.node_max_size
}

##########################################
# AWS Load Balancer Controller Module
##########################################

module "alb" {
  source = "../../modules/alb"

  environment       = var.environment
  cluster_name      = var.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_issuer_url   = module.eks.oidc_issuer_url
}