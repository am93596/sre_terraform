# Let's set up our cloud provider with Terraform

provider "aws" {
    region = "eu-west-1"

}

# Let's start with launching an EC2 instance using the app AMI
# define the resource name

resource "aws_instance" "app_instance" {
    ami = "ami-00e8ddf087865b27f"
    instance_type = "t2.micro"
    associate_public_ip_address = true
    tags = {
       Name = "sre_amy_terraform_app"
    }
}
# ami ID: ` `
# `sre_key.pem` file
# AWS keys setup (already done)
# public IP
# type of instance: `t2.micro`
 