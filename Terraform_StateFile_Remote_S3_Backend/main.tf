# Create ec2 Instance

resource "aws_instance" "ec2" {  
  instance_type = "t2.micro"
  ami = "ami-0cd59ecaf368e5ccf"
  tags = {
    name = "ec2 for Terraform State"
  }
}


  