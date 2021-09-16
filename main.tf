# Let's set up our cloud provider with Terraform

provider "aws" {
    region = "eu-west-1"
}

# Adding a VPC
resource "aws_vpc" "sre_amy_terraform_vpc" {
  cidr_block = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "sre_amy_terraform_vpc"
  }
}

# Adding a public subnet
resource "aws_subnet" "sre_amy_terraform_public_subnet" {
    vpc_id = var.vpc_id
    cidr_block = var.public_subnet_cidr
    map_public_ip_on_launch = "true"    # Makes the subnet public
    availability_zone = "eu-west-1a"

    tags = {
      Name = "sre_amy_terraform_public_subnet"
    }
}

# Adding an internet gateway
resource "aws_internet_gateway" "sre_amy_terraform_ig" {
  vpc_id = var.vpc_id

  tags = {
    Name = "sre_amy_terraform_ig"
  }
}

# Adding IG to default route table
resource "aws_route" "sre_amy_route_ig_connection" {
    route_table_id = var.def_route_table_id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = var.internet_gateway_id
}
# Adding a route table
# resource "aws_route_table" "public" {
#     vpc_id = "${var.vpc_id}"

#     route {
#         cidr_block = "0.0.0.0/0"
#         gateway_id = "????"
#     }

#     tags = {
#         Name = "${var.name}-public"
#     }
# }

# data "aws_internet_gateway" "default" {
#     filter {
#         name = "attachment.vpc-id"
#         values = ["${var.vpc_id}"]
#     }
# }

# Adding an app security group
resource "aws_security_group" "sre_amy_terraform_app_sg_2"  {
    name = "sre_amy_terraform_app_sg_2"
    description = "sre_amy_terraform_app_sg_2"
    vpc_id = var.vpc_id
    ingress {
        from_port = "80"
        to_port = "80"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] 
    }
    ingress {
        from_port = "22"
        to_port = "22"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = "3000"
        to_port = "3000"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]  
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1" # allow all
        cidr_blocks = ["0.0.0.0/0"]
    }

  tags = {
    Name = "sre_amy_terraform_app_sg_2"
  }
}

# Let's start with launching an EC2 instance using the app AMI
# define the resource name

resource "aws_instance" "app_instance" {
    ami = var.webapp_ami_id
    subnet_id = var.public_subnet_id
    instance_type = var.instance_type
    associate_public_ip_address = true
    tags = {
       Name = "sre_amy_terraform_app"
    }
    vpc_security_group_ids = [var.app_sg]
    key_name = var.aws_key_name
    connection {
		type = "ssh"
		user = "ubuntu"
		private_key = var.aws_key_path
		host = "${self.associate_public_ip_address}"
	} 

	# # export private ip of mongodb instance and start app
	# provisioner "remote-exec"{
	# 	inline = [
    #         "echo \"export DB_HOST=${var.mongodb_private_ip}\" >> /home/ubuntu/.bashrc",
	# 		"cd app",
    #         "npm start"
	# 	]
	# }
}

# step1 create a vpc with your cidr block
# run terraform plan then terraform apply
# get the vpc id from aws or terraform logs


# ami ID: ` `
# `sre_key.pem` file
# AWS keys setup (already done)
# public IP
# type of instance: `t2.micro`
 