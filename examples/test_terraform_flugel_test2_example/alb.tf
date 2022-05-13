resource "aws_vpc" "main" {
  cidr_block       = "10.10.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "sbnt1" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block             = "10.10.0.0/24"
  availability_zone = "us-east-2a"
#  map_public_ip_on_launch = true
  tags = {
    Name = "LB"
  }
}

resource "aws_subnet" "sbnt2" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block             = "10.10.1.0/24"
  availability_zone = "us-east-2b"
#  map_public_ip_on_launch = true
  tags = {
    Name = "LB"
  }
}

resource "aws_subnet" "sbnt_pub" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block             = "10.10.10.0/24"
  availability_zone = "us-east-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public"
  }
}

resource "aws_internet_gateway" "my_ig" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Main VPC - Internet Gateway"
  }
}

resource "aws_route_table" "my_vpc_us_east_2_public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_ig.id
  }

  tags = {
    Name = "Public Subnet Route Table."
  }
}

resource "aws_route_table_association" "my_vpc_us_east_2_public_sbnt1" {
  subnet_id = aws_subnet.sbnt1.id
  route_table_id = aws_route_table.my_vpc_us_east_2_public.id
}

resource "aws_route_table_association" "my_vpc_us_east_2_public_sbnt2" {
  subnet_id = aws_subnet.sbnt2.id
  route_table_id = aws_route_table.my_vpc_us_east_2_public.id
}


resource "aws_security_group" "lb_sg" {
  name        = "LB_SG"
  description = "My ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.main.cidr_block]
#    ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = var.tag_name
  }
}


resource "aws_lb" "nginx" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.sbnt1.id, aws_subnet.sbnt2.id]

#  enable_deletion_protection = true
#
#  access_logs {
#    bucket  = aws_s3_bucket.lb_logs.bucket
#    prefix  = "test-lb"
#    enabled = true
#  }

  tags = {
    Environment = "dev"
  }
}

resource "aws_lb_target_group" "lb_tg" {
  name        = "tf-lb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.nginx.arn
  port              = "25270"
  protocol          = "HTTP"
#  ssl_policy        = "ELBSecurityPolicy-2016-08"
#  certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_tg.arn
  }
}