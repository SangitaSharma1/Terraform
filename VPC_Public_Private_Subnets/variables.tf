variable "aws_key_pair" {
  default   = "MyAnsibleKey"
}


variable "aws_region" {
    description = "EC2 Region for the VPC"
    default = "ap-south-1"
}

variable "amis" {
    description = "AMIs by region"
    default = {
        ap-south-1 = "ami-0123b531fc646552f" # ubuntu 14.04 LTS
    }
}

variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
    description = "CIDR for the Public Subnet"
    default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
    description = "CIDR for the Private Subnet"
    default = "10.0.2.0/24"
}
