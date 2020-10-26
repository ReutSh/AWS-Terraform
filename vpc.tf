
# VPC
resource "aws_vpc" "reut_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "reut_vpc"
  }
}

#Nat gatways for the private subnets
resource "aws_nat_gateway" "private_subnet" {
  count         = length(var.subnets_cidr_private)
  allocation_id = aws_eip.nat.*.id[count.index]
  subnet_id     = aws_subnet.private_subnet.*.id[count.index]
  tags = {
    Name = "NAT_${count.index}"
  }
}

# Internet Gateway
resource aws_internet_gateway "reut_igw" {
  vpc_id = aws_vpc.reut_vpc.id
  tags = {
    Name = "igw"
  }
}

# Subnets : public
resource aws_subnet "public_subnet" {
  count             = length(var.subnets_cidr_public)
  vpc_id            = aws_vpc.reut_vpc.id
  cidr_block        = var.subnets_cidr_public[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "public_subnet_${count.index + 1}"
  }
}

#Subnets : private
resource aws_subnet "private_subnet" {
  count             = length(var.subnets_cidr_private)
  vpc_id            = aws_vpc.reut_vpc.id
  cidr_block        = var.subnets_cidr_private[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "private_subnet_${count.index + 1}"
  }
}

