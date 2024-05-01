# Create an EC2 Auto Scaling Group - app
resource "aws_autoscaling_group" "three-tier-app-asg" {
  name                 = "three-tier-app-asg"
  launch_configuration = aws_launch_configuration.three-tier-app-lconfig.id
  vpc_zone_identifier  = aws_subnet.prisub_app[*].id
  min_size             = 2
  max_size             = 3
  desired_capacity     = 2
}

# Create a launch configuration for the EC2 instances
resource "aws_launch_configuration" "three-tier-app-lconfig" {
  name_prefix                 = "three-tier-app-lconfig"
  image_id                    = "ami-06aa3f7caf3a30282"
  instance_type               = "t2.micro"
  #key_name                    = "three-tier-app-asg-kp"
  security_groups             = [aws_security_group.three-tier-ec2-asg-sg-app.id]
  user_data                   = <<-EOF
                                #!/bin/bash

                                sudo yum install mysql -y

                                EOF
                                
  associate_public_ip_address = false
  lifecycle {
    #prevent_destroy = true
    ignore_changes  = all
  }
}

##############################################
# Create Load balancer - app tier
resource "aws_lb" "three-tier-app-lb" {
  name               = "three-tier-app-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.three-tier-alb-sg-app.id]
  #count              = length(var.cidr_public_subnet_web)
  subnets            = aws_subnet.prisub_app[*].id
  #subnets            = [aws_subnet.three-tier-pub-sub-1.id, aws_subnet.three-tier-pub-sub-2.id]

  tags = {
    Environment = "three-tier-app-lb"
  }
}


# Create Load Balancer listener - app tier
resource "aws_lb_listener" "three-tier-app-lb-listner" {
  load_balancer_arn = aws_lb.three-tier-app-lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.three-tier-app-lb-tg.arn
  }
}

# create load balancer larget group - app tier

resource "aws_lb_target_group" "three-tier-app-lb-tg" {
  name     = "three-tier-app-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myVPC.id

  health_check {
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

# Register the instances with the target group - app tier
resource "aws_autoscaling_attachment" "three-tier-app-asattach" {
   #count = length(data.aws_autoscaling_group.three-tier-app-asg.name)
  autoscaling_group_name = aws_autoscaling_group.three-tier-app-asg.name
  lb_target_group_arn   = aws_lb_target_group.three-tier-app-lb-tg.arn

}