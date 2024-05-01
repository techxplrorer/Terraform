module "ec2_instance" {
  source = "../Terraform_Module/modules/ec2"
  ami_id = var.ami_id
  instance_type = lookup(var.instance_type, terraform.workspace, "t2.micro")
}

