#Nat gatways for the private subnets
resource "aws_nat_gateway" "private_subnet" {
  count = 2
  allocation_id = aws_eip.nat.*.id[count.index]
  subnet_id     = aws_subnet.private_subnet.*.id[count.index]
  tags = {
    Name = "gw_nat-${count.index}"
  }
}

