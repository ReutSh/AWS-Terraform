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
 

 data "aws_route_table" "private_rt_A" {
  subnet_id = aws_subnet.Subnet[count.index]
}

resource "aws_route" "route_A" {
  route_table_id            = data.aws_route_table.private_rt_A.id
  destination_cidr_block    = "10.20.10.0/24"
  }

# Route table association with private subnets
resource aws_route_table_association "private_A" {
   subnet_id      = aws_subnet.Subnet[count.index]
   route_table_id = aws_route_table.private_rt_A.id
  }

 data "aws_route_table" "private_rt_B" {
  subnet_id = aws_subnet.Subnet[count.index]
}

resource "aws_route" "route_B" {
  route_table_id            = data.aws_route_table.private_rt_B.id
  destination_cidr_block    = "10.20.20.0/24"
  }

# Route table association with private subnets
resource aws_route_table_association "private_B" {
   subnet_id      = aws_subnet.Subnet[count.index]
   route_table_id = aws_route_table.private_rt_B.id
  }
