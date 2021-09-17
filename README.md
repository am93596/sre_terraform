 Terraform Orchestration
## What is terraform
Terraform is an Infrastructure As Code tool used to automate orchestration tasks.
### Why Terraform
Terraform is a user-friendly tool that helps you automate tasks such as creating an EC2 instance, setting up a VPC, and making the security groups for your EC2 instances. It is cloud independent, so it can be used to automate provisioning tasks for any cloud service, not just AWS. It is also lightweight, so it doesn't slow down your computer
#### Setting up Terraform
1. Go to the [official Terraform downloads page](https://www.terraform.io/downloads.html), and download the version for your operating system.  
2. Then unzip the file, and put it in your preferred location. (e.g. `C:\Users\amurp\terraform`)  
3. Copy the path for the location.  
4. Navigate to `Settings` -> `Advanced system settings`. Click `Environment Variables`. 
5. Then, in the `User variables` section, click `Path` then `Edit`.  
6. Click `New`, then paste the location and click `OK` for all 3 open pages.  
![terraform_env_var_img](https://user-images.githubusercontent.com/88166874/133647750-b30cd91b-33ba-4016-8b2b-fe823feb1a7d.PNG)  
5. To check that your installation is working, open a new command prompt, and run `terraform`; it should return a list of all the possible terraform commands:  
![terraform_commands_img](https://user-images.githubusercontent.com/88166874/133648233-c46a2598-423b-45d5-bcc7-d54b8a5eaa0b.PNG)  

##### Securing AWS keys for Terraform
1. Repeat step 4 of `Setting up Terraform` (above).
2. Then, in the `User variables` section, click `New`, and name the variable `AWS_ACCESS_KEY_ID`. In the `value` input box, paste in your AWS access key. Then click `OK`.  
3. Click `New` again, and name this variable `AWS_SECRET_ACCESS_KEY`. In the `value` input box, paste in your AWS secret key. Then click `OK`.  
4. Restart your command prompt/git bash/vs code.  

### Initialise Terraform
1. Create a directory for this project  
2. In that directory, create a file called main.tf  
3. In the file, paste in the following code to initialise terraform with provider AWS:  

```
provider "aws" {
    region = "eu-west-1"
}
```
4. Let's run this code in a new terminal with `terraform init`  
> Should get `Terraform has been successfully initialized!` message  

### Creating Resources on AWS
- Let's start with launching an EC2 instance using the app AMI
- We need:
    - ami ID
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
```# Let's set up our cloud provider with Terraform
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
    vpc_id = aws_vpc.sre_amy_terraform_vpc.id
    cidr_block = var.public_subnet_cidr
    map_public_ip_on_launch = "true"    # Makes the subnet public
    availability_zone = "eu-west-1a"
    tags = {
      Name = "sre_amy_terraform_public_subnet"
    }
}

# Adding a private subnet
resource "aws_subnet" "sre_amy_terraform_private_subnet" {
    vpc_id = aws_vpc.sre_amy_terraform_vpc.id
    cidr_block = var.private_subnet_cidr
    map_public_ip_on_launch = "true"
    availability_zone = "eu-west-1a"
    tags = {
      Name = "sre_amy_terraform_private_subnet"
    }
}

# Adding an internet gateway
resource "aws_internet_gateway" "sre_amy_terraform_ig" {
  vpc_id = aws_vpc.sre_amy_terraform_vpc.id
  tags = {
    Name = "sre_amy_terraform_ig"
  }
}

# Adding IG to default route table
resource "aws_route" "sre_amy_route_ig_connection" {
    route_table_id = aws_vpc.sre_amy_terraform_vpc.default_route_table_id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sre_amy_terraform_ig.id
}

# Adding an app security group
resource "aws_security_group" "sre_amy_terraform_app_sg_2"  {
    name = "sre_amy_terraform_app_sg_2"
    description = "sre_amy_terraform_app_sg_2"
    vpc_id = aws_vpc.sre_amy_terraform_vpc.id
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

# Adding a db security group
resource "aws_security_group" "sre_amy_terraform_db_sg"  {
    name = "sre_amy_terraform_db_sg"
    description = "sre_amy_terraform_db_sg"
    vpc_id = aws_vpc.sre_amy_terraform_vpc.id
    ingress {
        from_port = "22"
        to_port = "22"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = "27017"
        to_port = "27017"
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
    Name = "sre_amy_terraform_db_sg"
  }
}

# Let's launch an EC2 instance using the db AMI
resource "aws_instance" "db_instance" {
    ami = var.db_ami_id
    subnet_id = aws_subnet.sre_amy_terraform_private_subnet.id
    instance_type = var.instance_type
    associate_public_ip_address = true
    tags = {
       Name = "sre_amy_terraform_db"
    }
    vpc_security_group_ids = [aws_security_group.sre_amy_terraform_db_sg.id]
    key_name = var.aws_key_name
    connection {
		type = "ssh"
		user = "ubuntu"
		private_key = var.aws_key_path
		host = db_instance.db_instance.public_ip
	} 
}

# Let's launch an EC2 instance using the app AMI
resource "aws_instance" "app_instance" {
    ami = var.webapp_ami_id
    subnet_id = aws_subnet.sre_amy_terraform_public_subnet.id
    instance_type = var.instance_type
    associate_public_ip_address = true
    tags = {
       Name = "sre_amy_terraform_app"
    }
    vpc_security_group_ids = [aws_security_group.sre_amy_terraform_app_sg_2.id]
    key_name = var.aws_key_name
    connection {
		type = "ssh"
		user = "ubuntu"
		private_key = var.aws_key_path
		host = aws_instance.app_instance.public_ip
	}
}
```
- Make sure you have the relevant variables in a file called `variable.tf`
- Make an `output.tf` file with the following contents:
```
output "npm_start_command" {
    value = "npm start"
}

output "node_seeds_command" {
    value = "node seeds/seed.js"
}

output "cd_app_command" {
    value = "cd app"
}

output "db_host_line" {
    value = "export DB_HOST=${aws_instance.db_instance.public_ip}:27017/posts/"
}

output "app_instance_ssh_command" {
    value = "ssh -i ${var.aws_key_path} ubuntu@${aws_instance.app_instance.public_ip}"
}
```
- Run `terraform plan` and `terraform apply`
- Ssh into the machine with the relevant key -> change `root` to `ubuntu`, and check the path for the key
