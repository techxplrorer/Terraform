# web tier load balancer security group 
resource "aws_security_group" "three-tier-alb-sg-web" {
  name        = "three-tier-alb-sg-web"
  description = "load balancer security group for web tier"
  vpc_id      = aws_vpc.myVPC.id
  depends_on = [
    aws_vpc.myVPC
  ]

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "three-tier-alb-sg-web"
  }
}

# web tier auto scalling group - Security Group
resource "aws_security_group" "three-tier-ec2-asg-sg-web" {
  name        = "three-tier-ec2-asg-sg"
  description = "Allow traffic from VPC"
  vpc_id      = aws_vpc.myVPC.id
  depends_on = [
    aws_vpc.myVPC
  ]

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
  }
  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    security_groups  = [aws_security_group.three-tier-alb-sg-web.id]
    #cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    security_groups  = [aws_security_group.three-tier-alb-sg-web.id]
    #cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "three-tier-ec2-asg-sg-web"
  }
}

#############################################################

# App tier Load balancer security group
resource "aws_security_group" "three-tier-alb-sg-app" {
  name        = "three-tier-alb-sg-app"
  description = "load balancer security group for app tier"
  vpc_id      = aws_vpc.myVPC.id
  depends_on = [
    aws_vpc.myVPC
  ]

  ingress {
    from_port          = "22"
    to_port            = "22"
    protocol           = "tcp"
    #security_groups    = [aws_security_group.three-tier-ec2-asg-sg-web.id]
    security_groups  = [aws_security_group.three-tier-alb-sg-web.id]
  }

  ingress {
    from_port          = "80"
    to_port            = "80"
    protocol           = "tcp"
    #security_groups    = [aws_security_group.three-tier-ec2-asg-sg-web.id]
    security_groups  = [aws_security_group.three-tier-alb-sg-web.id]
  }

  ingress {
    from_port          = "443"
    to_port            = "443"
    protocol           = "tcp"
    #security_groups    = [aws_security_group.three-tier-ec2-asg-sg-web.id]
    security_groups  = [aws_security_group.three-tier-alb-sg-web.id]
  }  

  tags = {
    Name = "three-tier-alb-sg-app"
  }
}

# app tier auto scaling group - Security Group
resource "aws_security_group" "three-tier-ec2-asg-sg-app" {
  name        = "three-tier-ec2-asg-sg-app"
  description = "Allow traffic from web tier"
  vpc_id      = aws_vpc.myVPC.id
  depends_on = [
    aws_vpc.myVPC
  ]

  ingress {
    from_port = "-1"
    to_port   = "-1"
    protocol  = "icmp"
    #security_groups  = [aws_security_group.three-tier-alb-sg-app.id]
    security_groups    = [aws_security_group.three-tier-ec2-asg-sg-web.id]
  }
  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    #security_groups  = [aws_security_group.three-tier-alb-sg-app.id]
    security_groups    = [aws_security_group.three-tier-ec2-asg-sg-web.id]
  }
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    #security_groups  = [aws_security_group.three-tier-alb-sg-app.id]
    security_groups    = [aws_security_group.three-tier-ec2-asg-sg-web.id]
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "three-tier-ec2-asg-sg-app"
  }
}

#####################################################################################################################

# Database tier Security gruop
resource "aws_security_group" "three-tier-db-sg" {
  name        = "three-tier-db-sg"
  description = "allow traffic from app tier"
  vpc_id      = aws_vpc.myVPC.id

  #ingress {
    #from_port       = 3306
    #to_port         = 3306
    #protocol        = "tcp"
    #security_groups = [aws_security_group.three-tier-ec2-asg-sg-app.id]
    #cidr_blocks     = ["0.0.0.0/0"]
  #}


  ingress {
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["10.0.3.0/24" , "10.0.4.0/24"]  #security group not working so CIDR
    description      = "Access for the web ALB SG"
    #security_groups = [aws_security_group.three-tier-alb-sg-app.id]
    #security_groups = [aws_security_group.three-tier-ec2-asg-sg-web.id]
  }


  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    #security_groups = [aws_security_group.three-tier-alb-sg-app.id]
    #security_groups = [aws_security_group.three-tier-ec2-asg-sg-app.id]
    cidr_blocks     = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "three-tier-db-sg"
  }  
}
