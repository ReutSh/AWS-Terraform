#Load Balancer

resource "aws_elb" "reutlb" {
  name               = "reutlb"
  availability_zones = var.azs

  access_logs {
    bucket        = "reut"
    bucket_prefix = "lb"
    interval      = 60
  }

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
  instances                   = aws_instance.Reut_test[count.index]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "reutlb"
  }
}
