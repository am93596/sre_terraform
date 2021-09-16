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
- Add them to the file, then run the command `terraform plan`
- That should tell you all the things that Terraform will do
- Then run `terraform apply` - it will ask if you want to perform the actions - enter `yes`
- That tells Terraform to run the actions it listed when you ran `terraform plan`
- Should give you a success message (`Apply complete!"`)