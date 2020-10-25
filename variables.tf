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