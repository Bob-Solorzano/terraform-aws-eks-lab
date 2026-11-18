##########################################
# General Variables
##########################################

variable "environment" {
  description = "Environment name."
  type        = string
}

##########################################
# Network Variables
##########################################

variable "vpc_id" {
  description = "VPC ID where security groups will be created."
  type        = string
}