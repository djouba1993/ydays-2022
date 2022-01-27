```
provider "aws" {
    region = "us-east-2"
    access_key = ""
    secret_key = ""
}
resource "aws_security_group" "instance_sg" {
    name = "ec2-ynov-sg"

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}


variable "NBR_INSTANCE" {
    type = number
    default = 2
}

resource "aws_instance" "my_ec2_instance" {
    count = var.NBR_INSTANCE
    ami = "ami-08962a4068733a2b6"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.instance_sg.id]
    key_name = "my-key-ec2"
    user_data = <<-EOF
        #!/bin/bash
        sudo apt-get update
        sudo apt-get install -y apache2
        sudo systemctl start apache2
        sudo systemctl enable apache2
        sudo echo "<h1>Hello Pole Presta</h1>" > /var/www/html/index.html

    EOF


    tags = {
        Name = "ec2_ynov"
    }
}

resource "aws_elb" "elb_ynov" {
  name                        = "ynov"
  instances           = ["i-0247eb0b03ca95822", "i-0b11f647193d7ff1b"]
  subnets                     = ["subnet-7bfc1506"]
  security_groups             = ["sg-08b56995aa5f4a238"]
  cross_zone_load_balancing   = true
  idle_timeout                = 60
  connection_draining         = true
  connection_draining_timeout = 300
  internal                    = true

  listener {
    instance_port      = 80
    instance_protocol  = "HTTP"
    lb_port            = 80
    lb_protocol        = "HTTP"

  }

  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 2
    interval            = 30
    target              = "HTTP:80/"
    timeout             = 5
  }
  
  tags = {
    Owner       = "ydays"
    Environment = "dev"
  }
}
```
