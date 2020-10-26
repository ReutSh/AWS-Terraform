variable aws_region {    
type = string
default = "us-east-1"
}

variable vpc_name {
type = string
default = "reut_vpc"
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
default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "subnets_cidr_private" {
type = list
default = ["10.0.10.0/24", "10.0.20.0/24"]
}