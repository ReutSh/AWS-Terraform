#Load Balancer

resource "aws_elb" "nginx" {
  name      = "nginx-elb"
  subnets   = [aws_subnet.public_subnet[0].id, aws_subnet.public_subnet[1].id]
  instances = [aws_instance.nginx[0].id, aws_instance.nginx[1].id]
  security_groups = [aws_security_group.nginx_instnaces_access.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  tags = {
    Name = "nginx-elb"
  }
}
