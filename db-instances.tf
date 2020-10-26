resource "aws_instance" "reut_db" {
  count = 2
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"
  user_data = file("nginx.sh")
  key_name = "Reut"
  subnet_id = aws_subnet.private_subnet.*.id[count.index]
   tags = {
      Name = "reut_db ${count.index}" 
      purpose = "terraform hw exe4"  
    }
  }