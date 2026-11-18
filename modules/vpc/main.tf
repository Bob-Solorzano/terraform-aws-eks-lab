
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.environment}-${var.vpc_name}-vpc"
    Environment = var.environment
  }
}

##################################
# Public Subnet definition
##################################

resource "aws_subnet" "public" {
  for_each = toset(var.public_subnet_cidrs)

  vpc_id     = aws_vpc.this.id
  cidr_block = each.value

  availability_zone = element(
    var.availability_zones,
    index(var.public_subnet_cidrs, each.value)
  )

  map_public_ip_on_launch = true

  tags = {
    Name                     = "${var.environment}-public-${each.value}"
    Tier                     = "public"
    Environment              = var.environment
    "kubernetes.io/role/elb" = "1"
  }
}

##################################
# Internet Gateway definition
##################################

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "${var.environment}-${var.internet_gw_name}-intgw"
    Environment = var.environment
  }
}

##################################
# Public Route Table
##################################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name        = "${var.environment}-public-rt"
    Tier        = "public"
    Environment = var.environment
  }
}

##################################
# Public Route Table Association
##################################

resource "aws_route_table_association" "this" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

##################################
# NAT Gateway definition
##################################

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name        = "${var.environment}-nat-eip"
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = values(aws_subnet.public)[0].id

  depends_on = [
    aws_internet_gateway.this
  ]

  tags = {
    Name        = "${var.environment}-nat-gateway"
    Environment = var.environment
  }
}

##################################
# Private Route Table
##################################

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name        = "${var.environment}-private-rt"
    Tier        = "private"
    Environment = var.environment
  }
}

##################################
# Private Subnet definition
##################################

resource "aws_subnet" "private" {
  for_each = toset(var.private_subnet_cidrs)

  vpc_id     = aws_vpc.this.id
  cidr_block = each.value

  availability_zone = element(
    var.availability_zones,
    index(var.private_subnet_cidrs, each.value)
  )

  map_public_ip_on_launch = false

  tags = {
    Name                              = "${var.environment}-private-${each.value}"
    Tier                              = "private"
    Environment                       = var.environment
    "kubernetes.io/role/internal-elb" = "1"
  }
}

##################################
# Private Route Table Association
##################################

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
