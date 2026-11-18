
##########################################
# VPC Outputs
##########################################

output "vpc_id" {
  value = aws_vpc.this.id
}

##########################################
# Public Subnet Outputs
##########################################

output "public_subnet_ids" {
  description = "IDs of the public subnets"

  value = [
    for subnet in aws_subnet.public :
    subnet.id
  ]
}

##########################################
# Private Subnet Outputs
##########################################

output "private_subnet_ids" {
  description = "IDs of the private subnets"

  value = [
    for subnet in aws_subnet.private :
    subnet.id
  ]
}

##########################################
# NAT Gateway Output
##########################################

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"

  value = aws_nat_gateway.this.id
}
