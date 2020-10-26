resource "aws_instance" "reut_db" {
  count         = 2
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"
  key_name      = var.key_name
  subnet_id     = aws_subnet.private_subnet.*.id[count.index]
  vpc_security_group_ids = [aws_security_group.DB_instnaces_access.id]

  tags = {
    Name    = "DB-${count.index + 1}"
    purpose = "terraform hw exe4"
  }
}