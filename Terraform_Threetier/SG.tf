
/*
# Create Secuirty Group for Application Load Balancer

resource "aws_security_group" "Alb_sg" {
  name   = "ALB-Security-Group"
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "Application Load Balancer - SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "Enbale_http" {
  security_group_id = aws_security_group.Alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "Enbale_https" {
  security_group_id = aws_security_group.Alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}


resource "aws_vpc_security_group_egress_rule" "Outbound_ALB" {
  security_group_id = aws_security_group.Alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#############################################################################################
# Create Secuirty Group for Application Tier

resource "aws_security_group" "ssh_sg" {
  name   = "SSH-Security-Group"
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "SSH-Security-Group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "SSH_to_WebServer" {
  security_group_id = aws_security_group.ssh_sg.id
  cidr_ipv4         = var.ssh-locate
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "Outbound_ssh" {
  security_group_id = aws_security_group.ssh_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

########################################################################
##    Create Security Group for Presentaion Tier (web)    ######
#######################################################################


resource "aws_security_group" "web-sg" {
  name        = "webserver-security-group"
  vpc_id      = aws_vpc.myVPC.id
  description = "Enable http/https and ssh access from security group Alb_sg & ssh_sg"


  ingress {
    description     = "http access"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.Alb_sg.id}"]
  }

  ingress {
    description     = "https access"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = ["${aws_security_group.Alb_sg.id}"]
  }

  ingress {
    description     = "ssh access"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.ssh_sg.id}"]
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = {
    Name = "webserver-security-group"
  }
}


########################################################################
##    Create Security Group for Database Tier (web)    ######
#######################################################################


resource "aws_security_group" "db-sg" {
  name        = "Database-security-group"
  vpc_id      = aws_vpc.myVPC.id
  description = "Enable MySQl access on port 3306 and allow traffic only from webserver-security-group"


  ingress {
    description     = "MySQL access"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.web-sg.id}"]
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = {
    Name = "Database-security-group"
  }
}

*/