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
