data "aws_availability_zones" "available" {}

provider "aws" {
  profile = "reut"
	region = var.aws_region
}

# VPC
resource "aws_vpc" "Reut_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
  Name = "ReutVPC"    
  }
}  

# Internet Gateway
resource aws_internet_gateway "reut_igw1" {
vpc_id = aws_vpc.Reut_vpc.id
tags = {
Name = "main_igw"
    }
}

# Subnets : public
resource aws_subnet "Subnet" {
count = length(var.subnets_cidr_public)
vpc_id = aws_vpc.Reut_vpc.id
cidr_block = element(var.subnets_cidr_public, count.index)
availability_zone = element(var.azs ,count.index)
  tags = {
    Name = "Subnet-${count.index+1}"
  }
}

#Subnets : private
resource aws_subnet "private_subnet" {
vpc_id = aws_vpc.Reut_vpc.id
cidr_block = element(var.subnets_cidr_private, count.index)
availability_zone = element(var.azs ,count.index)
  tags = {
  Name = "private_subnet-${count.index}"  
  }
}


#Elastic IP
resource aws_eip "nat" {
vpc = true
}

#Security Group 

resource "aws_security_group" "nginx_instnaces_access" {
  vpc_id = aws_vpc.Reut_vpc.id
  name   = "nginx-access" 
  }

resource "aws_security_group_rule" "nginx_http_acess" {
  description       = "allow http access from anywhere"
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.nginx_instnaces_access.id
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  }

resource "aws_security_group_rule" "nginx_outbound_anywhere" {
  description = "allow outbound traffic to anywhere"
  from_port = 0
  protocol = "-1"
  security_group_id = aws_security_group.nginx_instnaces_access.id
  to_port = 0
  type = "egress"
  cidr_blocks = ["0.0.0.0/0"]
 }

  resource "aws_eip" "pub_ip" {
  count = 2
  instance = aws_instance.Reut_terraform_test[count.index]
  vpc      = true
  }
