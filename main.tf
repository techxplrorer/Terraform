resource "aws_vpc" "myVPC" {
  cidr_block = var.cidr

  tags = {
    Name = "VPC_Demo"
  }
}

resource "aws_subnet" "pubsub" {
  vpc_id                  = aws_vpc.myVPC.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public_Subnet"
  }
}

resource "aws_subnet" "prisub" {
  vpc_id                  = aws_vpc.myVPC.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "Private_Subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myVPC.id
  tags = {
    Name = "Internet_Gateway"
  }
}

resource "aws_route_table" "pubRT" {
  vpc_id = aws_vpc.myVPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "Public_RouteTable"
  }
}

resource "aws_route_table_association" "pubrta" {
  subnet_id      = aws_subnet.pubsub.id
  route_table_id = aws_route_table.pubRT.id
}

resource "aws_eip" "myeip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "NAT" {
  allocation_id = aws_eip.myeip.id
  subnet_id     = aws_subnet.pubsub.id

}

resource "aws_route_table" "priRT" {
  vpc_id = aws_vpc.myVPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NAT.id
  }
  tags = {
    Name = "Private_RouteTable"
  }
}

resource "aws_route_table_association" "prirta" {
  subnet_id      = aws_subnet.prisub.id
  route_table_id = aws_route_table.priRT.id
}

# Create Secuirty Group for Public Instance

resource "aws_security_group" "web-sg-pub" {
  name   = "web-sg-pub"
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "Public-SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "TLS_from_VPC" {
  security_group_id = aws_security_group.web-sg-pub.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "SSH_from_VPC" {
  security_group_id = aws_security_group.web-sg-pub.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.web-sg-pub.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Create Secuirty Group for Private Instance

resource "aws_security_group" "web-sg-pri" {
  name   = "web-sg-pri"
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "Private-SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "SSH_from_pubsub" {
  security_group_id = aws_security_group.web-sg-pri.id
  cidr_ipv4         = "10.0.0.0/24"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_pubsub" {
  security_group_id = aws_security_group.web-sg-pri.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}



#bucket name should be loweracase
resource "aws_s3_bucket" "example" {
  bucket = "idrisprojectforterraformaws"
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_instance" "webserver1" {
  ami                         = "ami-06aa3f7caf3a30282"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.web-sg-pub.id]
  subnet_id                   = aws_subnet.pubsub.id
  associate_public_ip_address = true
  user_data                   = base64encode(file("userdata.sh"))

  #First Method (create keyPair in AWS console and give the name here)
  #key_name = "Demo"

  key_name = "aws_keys_pairs"


  tags = {
    Name = "Bastion Host"
  }
}

#Second Method 
#resource "aws_key_pair" "TF_Key" {
#  key_name   = "TF_Key"
#  public_key = tls_private_key.rsa.public_key_openssh
#}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


#local private key saved in the working directory 
# To ssh chmod 0400 "filename " (Here filename may not .pem extension )
#resource "local_file" "tf_Key" {
#  content  = tls_private_key.rsa.private_key_pem
#  filename = "tfkey"
#}

resource "aws_key_pair" "generated_key" {

  # Name of key : Write custom name of your key
  key_name   = "aws_keys_pairs"

  # Public Key : The public will be generated using the refernce of tls_private_key.terrafrom_generated_private_key
  public_key = tls_private_key.rsa.public_key_openssh

  # Store private key :  Generate and save private key(aws_keys_pairs.pem) in currect directory
  provisioner "local-exec" {
    command = <<-EOT
      echo '${tls_private_key.rsa.private_key_pem}' > aws_keys_pairs.pem
      chmod 400 aws_keys_pairs.pem
    EOT
  }
}


resource "aws_instance" "webserver2" {
  ami                    = "ami-06aa3f7caf3a30282"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web-sg-pri.id]
  subnet_id              = aws_subnet.prisub.id
  user_data              = base64encode(file("champ.sh"))
  tags = {
    Name = "Private Instance"
  }
}
