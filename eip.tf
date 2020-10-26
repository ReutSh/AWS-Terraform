#Elastic IP nat
resource aws_eip "nat" {
count = length(var.subnets_cidr_private)
vpc = true
}

#Elastic IP Public 
  resource "aws_eip" "pub_ip" {
  count = 2
  instance = aws_instance.reut_web[count.index]
  vpc      = true
  }
