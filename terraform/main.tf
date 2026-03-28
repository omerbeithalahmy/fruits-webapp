module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "${var.project_name}-vpc"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = [cidrsubnet(var.vpc_cidr, 8, 1), cidrsubnet(var.vpc_cidr, 8, 2)]
  public_subnets  = [cidrsubnet(var.vpc_cidr, 8, 101), cidrsubnet(var.vpc_cidr, 8, 102)]

  enable_nat_gateway = true
  single_nat_gateway = true 

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

resource "aws_security_group" "alb_sg" {
    name = "${var.project_name}-alb-sg"
    description = "Allow HTTP inbound traffic to ALB"
    vpc_id = module.vpc.vpc_id

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "ec2_sg" {
    name = "${var.project_name}-ec2-sg"
    description = "Allow inbound traffic from ALB only"
    vpc_id = module.vpc.vpc_id

    ingress {
        from_port = 3000
        to_port = 3000
        protocol = "tcp"
        security_groups = [aws_security_group.alb_sg.id]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.vpc_cidr]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_lb" "app_lb" {
    name = "${var.project_name}-alb"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.alb_sg.id]
    subnets = module.vpc.public_subnets
}

resource "aws_lb_target_group" "app_tg" {
    name = "${var.project_name}-tg"
    port = 3000
    protocol = "HTTP"
    vpc_id = module.vpc.vpc_id
  
    health_check {
      path = "/"
      interval = 30
      timeout = 5
      healthy_threshold = 2
      unhealthy_threshold = 2
    }
}

resource "aws_lb_listener" "front_end" {
    load_balancer_arn = aws_lb.app_lb.arn
    port = "80"
    protocol = "HTTP"
 
    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.app_tg.arn
    }
}

data "aws_ami" "ubuntu" {
    most_recent = true
    owners = ["099720109477"]

    filter {
      name = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }
}

resource "aws_launch_template" "app_lt" {
    name_prefix = "${var.project_name}-lt"
    image_id = data.aws_ami.ubuntu.id
    instance_type = var.instance_type

    network_interfaces {
      associate_public_ip_address = false 
      security_groups = [aws_security_group.ec2_sg.id]
    }

    user_data = base64encode(<<-EOF
      #!/bin/bash
      apt-get update -y
      apt-get install -y git docker.io docker-compose
      systemctl start docker
      systemctl enable docker
      
      git clone -b feat/webapp-provisioning ${var.github_repo_url} /home/ubuntu/app
      cd /home/ubuntu/app
      
      export TAG=$(git rev-parse --short HEAD)
      
      docker-compose pull
      docker-compose up -d
    EOF
    )

    tag_specifications {
      resource_type = "instance"
      tags = {
        Name = "${var.project_name}-server"
      }
    }
}

resource "aws_autoscaling_group" "app_asg" {
    name = "${var.project_name}-asg"
    vpc_zone_identifier = module.vpc.private_subnets
    target_group_arns = [aws_lb_target_group.app_tg.arn]
    health_check_type = "ELB"
    health_check_grace_period = 300

    min_size = 2
    max_size = 4
    desired_capacity = 2

    launch_template {
      id = aws_launch_template.app_lt.id
      version = "$Latest"
    }
}