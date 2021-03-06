#Web server instances
resource "aws_instance" "nginx" {
  count         = 2
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  user_data     = file("nginx.sh")
  key_name      = var.key_name
  subnet_id     = aws_subnet.public_subnet.*.id[count.index]
  vpc_security_group_ids = [aws_security_group.nginx_instnaces_access.id]
  associate_public_ip_address = true

  tags = {
    Name    = "Nginx-${count.index + 1}"
    purpose = "Terraform hw exe4"
  }
}