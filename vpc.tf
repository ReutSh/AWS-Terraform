variable aws_region {    
type = string
default = "us-east-1"
}

variable azs {
type = list
default = ["us-east-1a", "us-east-1b","us-east-1c"]
}

variable "vpc_cidr" {
type = string  
default = "10.20.0.0/16"
}

variable "subnets_cidr" {
type = list  
default = ["10.20.1.0/24", "10.20.2.0/24", "10.20.30.0/24", "10.20.40.0/24"]
}  

variable "subnets_cidr_public" {
type = list
default = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "subnets_cidr_private" {
type = list
default = ["10.20.10.0/24", "10.20.20.0/24"]
}

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
count = length(var.subnets_cidr)
vpc_id = aws_vpc.Reut_vpc.id
cidr_block = element(var.subnets_cidr, count.index)
availability_zone = element(var.azs ,count.index)
  tags = {
    Name = "Subnet-${count.index+1}"
  }
}


resource aws_route_table "public_rt" {
vpc_id = aws_vpc.Reut_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.reut_igw1.id
     }
   tags = {
    Name = "publicRouteTable"
   }
}

# Route table association with public subnets
resource aws_route_table_association "public" {
   count = length(var.subnets_cidr_public)
   subnet_id      = element(aws_subnet.Subnet.*.id, count.index)
   route_table_id = aws_route_table.public_rt.id
 }

#Elastic IP
resource aws_eip "nat" {
vpc = true
}


#Nat gatways for the private subnets
resource "aws_nat_gateway" "gw_Nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = "10.20.1.0/24"
  tags = {
    Name = "gw Nat"
  }
}
### I am missing a security group and how to enable elastic IP 
### to the instances so the nginx can run ssh to the machines.

data "aws_ami" "ubuntu" {
  most_recent = true 

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]  
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

 owners = ["099720109477"]
}

resource "aws_instance" "Reut_terraform_test" {
  count = 2
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  user_data = file("nginx2.sh")
  key_name = "Reut"
  subnet_id = element(aws_subnet.Subnet.*.id, count.index)
  
   tags = {
      Name = "Reut_terraform_test ${count.index}" 
      purpose = "Terraform hw exe4"  
    }
  }

module "web_server_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = "web-server"
  description = "Security group for web-server with HTTP ports open within VPC"
  vpc_id      = aws_vpc.Reut_vpc.id
  ingress_cidr_blocks = var.subnets_cidr_public
  }











