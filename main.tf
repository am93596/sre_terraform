# Let's set up our cloud provider with Terraform

provider "aws" {
    region = "eu-west-1"
}

# Adding a VPC
resource "aws_vpc" "sre_amy_terraform_vpc" {
  cidr_block = "10.102.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "sre_amy_terraform_vpc"
  }
}

# Adding a public subnet
resource "aws_subnet" "sre_amy_terraform_public_subnet" {
    vpc_id = "vpc-05a2bec2286496735"
    cidr_block = "10.102.1.0/24"
    map_public_ip_on_launch = "true"    # Makes the subnet public
    availability_zone = "eu-west-1a"

    tags = {
      "Name" = "sre_amy_terraform_public_subnet"
    }
}

# Adding an internet gateway
resource "aws_internet_gateway" "sre_amy_terraform_ig" {
  vpc_id = "vpc-05a2bec2286496735"

  tags = {
    Name = "sre_amy_terraform_ig"
  }
}

# Let's start with launching an EC2 instance using the app AMI
# define the resource name

# resource "aws_instance" "app_instance" {
#     ami = "ami-044774d37be69e57e"
#     instance_type = "t2.micro"
#     associate_public_ip_address = true
#     tags = {
#        Name = "sre_amy_terraform_app"
#     }
# }

# step1 create a vpc with your cidr block
# run terraform plan then terraform apply
# get the vpc id from aws or terraform logs


# ami ID: ` `
# `sre_key.pem` file
# AWS keys setup (already done)
# public IP
# type of instance: `t2.micro`
 