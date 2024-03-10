resource "aws_vpc" "myVPC" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "VPC_Demo"
  }
}

# Create Public Subnet within VPC at us-east-1a Zone 
resource "aws_subnet" "pubsub" {
  count                   = length(var.cidr_public_subnet)
  vpc_id                  = aws_vpc.myVPC.id
  cidr_block              = element(var.cidr_public_subnet, count.index)
  availability_zone       = element(var.us_availability_zone, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "Subnet-Public : Public Subnet ${count.index + 1}"
  }
}

# Create Private Subnet within VPC at multi-available Zone 
resource "aws_subnet" "prisub" {
  count                   = length(var.cidr_private_subnet)
  vpc_id                  = aws_vpc.myVPC.id
  cidr_block              = element(var.cidr_private_subnet, count.index)
  availability_zone       = element(var.us_availability_zone, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "Subnet-Private : Private Subnet ${count.index + 1}"
  }
}


# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myVPC.id
  tags = {
    Name = "Internet_Gateway"
  }
}

# Create Public Route Table
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

# Public Route Table Association
resource "aws_route_table_association" "pubrta" {
  count          = length(var.cidr_public_subnet)
  depends_on     = [aws_subnet.pubsub, aws_route_table.pubRT]
  subnet_id      = element(aws_subnet.pubsub[*].id, count.index)
  route_table_id = aws_route_table.pubRT.id
}

# Create Elastic IP
resource "aws_eip" "myeip" {
  count  = length(var.cidr_private_subnet)
  domain = "vpc"

  tags = {
    Name = "EIP- ${count.index + 1}"
  }
}

# Create NAT Gateway
resource "aws_nat_gateway" "NAT" {
  count         = length(var.cidr_public_subnet)
  depends_on    = [aws_eip.myeip]
  allocation_id = aws_eip.myeip[count.index].id
  subnet_id     = aws_subnet.pubsub[count.index].id
  tags = {
    Name = "NAT Gateway ${count.index + 1}"
  }
}

# Create Private Route Table
resource "aws_route_table" "priRT" {
  count      = length(var.cidr_private_subnet)
  vpc_id     = aws_vpc.myVPC.id
  depends_on = [aws_nat_gateway.NAT]
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NAT[count.index].id
  }
  tags = {
    Name = "Private_RouteTable ${count.index + 1}"
  }
}

# Private Route Table Association
resource "aws_route_table_association" "prirta" {
  count          = length(var.cidr_private_subnet)
  depends_on     = [aws_subnet.prisub, aws_route_table.priRT]
  subnet_id      = element(aws_subnet.prisub[*].id, count.index)
  route_table_id = aws_route_table.priRT[count.index].id
}

/*
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

# Create Security Group for Private Instance

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


#Create S3 Bucket (bucket name should be lowercase)
resource "aws_s3_bucket" "example" {
  bucket = "idrisprojectforterraformaws"
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

# Create ec2 instance in Public Subnet ( Named as Bastion Host)
resource "aws_instance" "webserver1" {
  ami                         = "ami-06aa3f7caf3a30282"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.web-sg-pub.id]
  subnet_id                   = aws_subnet.pubsub.id
  associate_public_ip_address = true
  user_data                   = base64encode(file("userdata.sh"))

  #First Method (create keyPair in AWS console and give the name in Key_name)
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


# Create Private Key 
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

#Create ec2 instance in Private Subnet ( Backend App server)
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
*/