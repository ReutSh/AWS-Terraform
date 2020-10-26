data "aws_availability_zones" "available" {}

provider "aws" {
  profile = "reut"
	region = var.aws_region
}

# VPC
resource "aws_vpc" "reut_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
  Name = "reutvpc"    
  }
}  

# Internet Gateway
resource aws_internet_gateway "reut_igw1" {
vpc_id = aws_vpc.reut_vpc.id
tags = {
Name = "main_igw"
    }
}

# Subnets : public
resource aws_subnet "public_subnet" {
count = length(var.subnets_cidr_public)
vpc_id = aws_vpc.reut_vpc.id
cidr_block = var.subnets_cidr_public[count.index]
availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "Subnet-${count.index+1}"
  }
}

#Subnets : private
resource aws_subnet "private_subnet" {
count  = length(var.subnets_cidr_private) 
vpc_id = aws_vpc.reut_vpc.id
cidr_block = var.subnets_cidr_private[count.index] 
availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
  Name = "private_subnet-${count.index}"  
  }
}

