module "ec2_instance" {
  source = "./modules/ec2"
  ami_id = "ami-0cd59ecaf368e5ccf"
  instance_type   =   "t2.micro"
}



  

