variable "vpc_cidr" {
  type        = string
  description = "Public Subnet CIDR values"
  #default     = "10.0.0.0/16"
}

variable "cidr_public_subnet" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  #default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "cidr_private_subnet" {
  type        = list(string)
  description = "Private Subnet CIDR values"
  #default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "us_availability_zone" {
  type        = list(string)
  description = "Availability Zones"
  #default     = ["us-east-1a", "us-east-1b"]
}

/*
variable "location" {
  type = string
  description = "Project region location"
}

variable "instance_type" {
  type        = string
  #default     = "t2.micro"
  description = "EC2 Instance Type"
}

variable "ami_id" {
  type        = string
  default     = ""
  description = "EC2 AMI ID"
}
*/
