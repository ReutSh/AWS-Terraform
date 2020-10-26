#Web server instances

data "aws_ami" "ubuntu" {
  most_recent = true 

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]  
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

 owners = ["099720109477"]
}

resource "aws_instance" "reut_web" {
  count = 2
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  user_data = file("nginx2.sh")
  key_name = "Reut"
  subnet_id = aws_subnet.Subnet_cidr_public.id[count.index]
   tags = {
      Name = "Reut_web ${count.index}" 
      purpose = "Terraform hw exe4"  
    }
  }