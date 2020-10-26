#Elastic IP nat
resource aws_eip "nat" {
  count = length(var.subnets_cidr_private)

  tags = {
    Name = "NAT-eip-${count.index + 1}"
  }
}