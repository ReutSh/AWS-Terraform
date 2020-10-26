# route table with target as NAT gateway
resource "aws_route_table" "nat_rt_private" {
  count = 2
  vpc_id = aws_vpc.reut_vpc.id
  nat_gateway_id = aws_nat_gateway.gw_nat[count.index]
    tags = {
    Name = "nat-route-table-${count.index}"
  }
}

# associate route table to private subnet
resource "aws_route_table_association" "associate_routetable_to_private_subnet" {
  count = 2
  subnet_id      = aws_subnet.private_subnet.*.id[count.index]
  route_table_id = aws_route_table.nat_rt_private.*.id[count.index]
 }