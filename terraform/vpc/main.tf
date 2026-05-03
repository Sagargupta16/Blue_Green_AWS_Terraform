################################################################################
# VPC Module - main.tf
#
# Provisions a two-AZ VPC with:
#   * 1 x Internet Gateway
#   * 2 x public  /24 subnets (one per AZ)
#   * 2 x private /24 subnets (one per AZ)
#   * 2 x NAT Gateways (one per AZ - fully HA egress, each with its own EIP)
#   * 1 x public route table (via IGW) shared by both public subnets
#   * 2 x private route tables (one per AZ, each via its AZ-local NAT)
#
# Subnet layout (assuming default vpc_cidr = 10.0.0.0/16):
#   public_subnet_1  -> 10.0.0.0/24   (AZ-a)
#   public_subnet_2  -> 10.0.1.0/24   (AZ-b)
#   private_subnet_1 -> 10.0.2.0/24   (AZ-a)
#   private_subnet_2 -> 10.0.3.0/24   (AZ-b)
################################################################################


################################################################################
# Core VPC
################################################################################

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
}


################################################################################
# Subnets
################################################################################

# ---- Public subnets (route to Internet Gateway) ------------------------------

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 0)
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = false
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 1)
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = false
}

# ---- Private subnets (route to per-AZ NAT Gateway) ---------------------------

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 2)
  availability_zone = var.availability_zones[0]
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 3)
  availability_zone = var.availability_zones[1]
}


################################################################################
# Internet Gateway & NAT Gateways
################################################################################

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_eip" "nat_eip_1" {
  domain = "vpc"
}

resource "aws_eip" "nat_eip_2" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway_1" {
  allocation_id = aws_eip.nat_eip_1.id
  subnet_id     = aws_subnet.public_subnet_1.id
}

resource "aws_nat_gateway" "nat_gateway_2" {
  allocation_id = aws_eip.nat_eip_2.id
  subnet_id     = aws_subnet.public_subnet_2.id
}


################################################################################
# Route tables and associations
################################################################################

# ---- Public route table (shared) --------------------------------------------

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public_subnet_1_assoc" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_assoc" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

# ---- Private route tables (one per AZ) --------------------------------------

resource "aws_route_table" "private_route_table_1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_1.id
  }
}

resource "aws_route_table" "private_route_table_2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_2.id
  }
}

resource "aws_route_table_association" "private_subnet_1_assoc" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table_1.id
}

resource "aws_route_table_association" "private_subnet_2_assoc" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table_2.id
}
