resource "aws_instance" "ec2" {
  ami = var.ami_id
  instance_type = var.instance_type
}

output "ec2_public_ip" {
    description = "Public IP address of the EC2 instance"
    value = aws_instance.ec2.public_ip
  
}
