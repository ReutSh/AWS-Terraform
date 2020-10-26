## Private
resource "aws_route_table" "private" {
  count  = length(var.subnets_cidr_private)
  vpc_id = aws_vpc.reut_vpc.id
  tags = {
    Name = "private_route_table_${count.index}"
  }
}

resource "aws_route" "private-route" {
  count                  = length(var.subnets_cidr_private)
  route_table_id         = aws_route_table.private.*.id[count.index]
  nat_gateway_id         = aws_nat_gateway.private_subnet.*.id[count.index]
  destination_cidr_block = "0.0.0.0/0"
}

# associate route table to private subnet
resource "aws_route_table_association" "private-association" {
  count          = length(var.subnets_cidr_private)
  subnet_id      = aws_subnet.private_subnet.*.id[count.index]
  route_table_id = aws_route_table.private.*.id[count.index]
}

## Public
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.reut_vpc.id
  tags = {
    Name = "public_route_table"
  }
}

resource "aws_route" "public-toute" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.reut_igw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public-association" {
  count          = length(var.subnets_cidr_public)
  subnet_id      = aws_subnet.public_subnet.*.id[count.index]
  route_table_id = aws_route_table.public.id
}