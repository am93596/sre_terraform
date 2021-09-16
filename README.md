 Terraform Orchestration
## What is terraform
### Why Terraform
#### Setting up Terraform
##### Securing AWS keys for Terraform

- Create env var to secure AWS keys
- Restart the terminal
- Create a file called main.tf
- Add the code to initialise terraform with provider AWS

```
provider "aws" {
    region = "eu-west-1"

}
```

- Let's run this code with `terraform init`
- Should get `Terraform has been successfully initialized!` message

### Creating Resources on AWS
- Let's start with launching an EC2 instance using the app AMI
- We need:
    - ami ID: ` `
    - `sre_key.pem` file
    - AWS keys setup (already done)
    - public IP
    - type of instance: `t2.micro`
- Add them to the file as follows:
```
# Let's start with launching an EC2 instance using the app AMI
# define the resource name

resource "aws_instance" "app_instance" {
    ami = "ami-044774d37be69e57e"
    instance_type = "t2.micro"
    associate_public_ip_address = true
    tags = {
       Name = "sre_amy_terraform_app"
    }
}
```
- then run the command `terraform plan`
- That should tell you all the things that Terraform will do
- Then run `terraform apply` - it will ask if you want to perform the actions - enter `yes`
- That tells Terraform to run the actions it listed when you ran `terraform plan`
- Should give you a success message (`Apply complete!"`)
- To terminate the instances, enter `terraform destroy`. It will ask if you want to perform the actions - enter `yes`
- Should give you a success message - `Destroy complete`

- Create file called `variable.tf`

### Create A VPC
- In the main.tf file, comment out the EC2 instance code, and paste this above it:
```
# Adding a VPC
resource "aws_vpc" "sre_amy_terraform_vpc" {
  cidr_block = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "sre_amy_terraform_vpc"
  }
}
```
- In Git Bash, run `terraform plan` and `terraform apply`
# Adding a subnet
- In the main.tf file, and paste this below the VPC code:
```
# Adding a public subnet
resource "aws_subnet" "sre_amy_terraform_public_subnet" {
    vpc_id = var.vpc_id
    cidr_block = var.public_subnet_cidr
    map_public_ip_on_launch = "true"    # Makes the subnet public
    availability_zone = "eu-west-1a"

    tags = {
      "Name" = "sre_amy_terraform_public_subnet"
    }
}
```
- In Git Bash, run `terraform plan` and `terraform apply`

# Adding an internet gateway
- In the main.tf file, and paste this below the subnet code:
```
# Adding an internet gateway
resource "aws_internet_gateway" "sre_amy_terraform_ig" {
  vpc_id = "vpc-05a2bec2286496735"

  tags = {
    "Name" = "sre_amy_terraform_ig"
  }
}
```
- In Git Bash, run `terraform plan` and `terraform apply`

# Adding an app security group
- In the main.tf file, and paste this below the internet gateway code:
```
# Adding an app security group
resource "aws_security_group" "sre_amy_terraform_app_sg"  {
    name = "sre_amy_terraform_app_sg"
    description = "sre_amy_terraform_app_sg"
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
    Name = "sre_amy_terraform_app_sg"
  }
}
```
- In Git Bash, run `terraform plan` and `terraform apply`

> Add your variable to the variable.tf file with the following syntax:  
> ```
> variable "vpc_id" {
>    default = "INSERT ID HERE"
>}

- Uncomment the ec2 creation code, and run `terraform plan` and `terraform apply`

# Final Main Code with VPC, IG, RT, SG, and EC2 instance
```
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
```
- Make sure you have the relevant variables in a file called `variable.tf`
- Comment out the contents of the main file, then uncomment the first section and run `terraform plan` and `terraform apply`. Uncomment the next section, add any necessary IDs made from the previous apply, then run `terraform plan` and `terraform apply`. Repeat this step until the whole file is being applied
- Ssh into the machine with the relevant key -> change `root` to `ubuntu`, and check the path for the key
