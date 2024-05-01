
######### Create an EC2 Auto Scaling Group - web ############
resource "aws_autoscaling_group" "three-tier-web-asg" {
  name                 = "three-tier-web-asg"
  launch_configuration = aws_launch_configuration.three-tier-web-lconfig.id
  health_check_type    = "ELB"
   #count               = length(var.cidr_public_subnet_web)
  vpc_zone_identifier = aws_subnet.pubsub[*].id
  #vpc_zone_identifier  = [aws_subnet.three-tier-pub-sub-1.id, aws_subnet.three-tier-pub-sub-2.id]
  min_size         = 2
  max_size         = 3
  desired_capacity = 2
}

###### Create a launch configuration for the EC2 instances #####
resource "aws_launch_configuration" "three-tier-web-lconfig" {
  name_prefix                 = "three-tier-web-lconfig"
  image_id                    = "ami-06aa3f7caf3a30282"
  instance_type               = "t2.micro"
  #key_name                    = "three-tier-web-asg-kp"
  security_groups             = [aws_security_group.three-tier-ec2-asg-sg-web.id]
  #user_data                   = base64encode(file("userdata.sh"))
  associate_public_ip_address = true
  lifecycle {
    #prevent_destroy = true
    ignore_changes  = all
  }
}

########################################################################################

# Create Load balancer - web tier
resource "aws_lb" "three-tier-web-lb" {
  name               = "three-tier-web-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.three-tier-alb-sg-web.id]
  #count              = length(var.cidr_public_subnet_web)
  subnets            = aws_subnet.pubsub[*].id
  #subnets            = [aws_subnet.three-tier-pub-sub-1.id, aws_subnet.three-tier-pub-sub-2.id]

  tags = {
    Environment = "three-tier-web-lb"
  }
}


# Create Load Balancer listener - web tier
resource "aws_lb_listener" "three-tier-web-lb-listner" {
  load_balancer_arn = aws_lb.three-tier-web-lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.three-tier-web-lb-tg.arn
  }
}

# create load balancer larget group - web tier

resource "aws_lb_target_group" "three-tier-web-lb-tg" {
  name     = "three-tier-web-lb-tg"
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

# Register the instances with the target group - web tier
resource "aws_autoscaling_attachment" "three-tier-web-asattach" {
   #count = length(data.aws_autoscaling_group.three-tier-web-asg.name)
  autoscaling_group_name = aws_autoscaling_group.three-tier-web-asg.name
  lb_target_group_arn   = aws_lb_target_group.three-tier-web-lb-tg.arn

}
