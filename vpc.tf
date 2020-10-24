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
resource "aws_nat_gateway" "gw_Nat1" {
  allocation_id = aws_eip.nat.id
  subnet_id     = "10.20.1.0/24"
  tags = {
    Name = "gw Nat1"
  }
}

resource "aws_nat_gateway" "gw_Nat2" {
  allocation_id = aws_eip.nat.id
  subnet_id     = "10.20.2.0/24"
  tags = {
    Name = "gw Nat2"
  }
}

#Web server instances

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
  	tags = {
    Name = "nginx_inbound_rule"
  }
}


resource "aws_security_group_rule" "nginx_outbound_anywhere" {
  description = "allow outbound traffic to anywhere"
  from_port = 0
  protocol = "-1"
  security_group_id = aws_security_group.nginx_instnaces_access.id
  to_port = 0
  type = "egress"
  cidr_blocks = ["0.0.0.0/0"]
    tags = {
    Name = "nginx_outbond_rule"
 }
}
  resource "aws_eip" "pub_ip" {
  count = 2
  instance = aws_instance.Reut_terraform_test[count.index]
  vpc      = true
  }


#Load Balancer

resource "aws_elb" "reutlb" {
  name               = "reutlb"
  availability_zones = var.azs

  access_logs {
    bucket        = "reut"
    bucket_prefix = "lb"
    interval      = 60
  }

  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener {
    instance_port      = 8000
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 30
  }
  instances                   = aws_instance.Reut_terraform_test[count.index]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "reutlb"
  }
}










