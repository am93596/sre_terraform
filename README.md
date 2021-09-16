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

- Let's run this code wtih `terraform init`
- Should get `Terraform has been successfully initialized!` message