# output "vpc_id" {
#     value = aws_vpc.sre_amy_terraform_vpc.id
# }

# output "internet_gateway_id" {
#     value = aws_internet_gateway.sre_amy_terraform_ig.id  
# }

# output "public_subnet_id" {
#     value = aws_subnet.sre_amy_terraform_public_subnet.id 
# }

# output "app_security_group_id" {
#     value = aws_security_group.sre_amy_terraform_app_sg_2.id
# }

# output "route_table_id" {
#     value = aws_vpc.sre_amy_terraform_vpc.default_route_table_id  
# }

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

# output "db_instance_ssh_command" {
#     value = "ssh -i ${var.aws_key_path} ubuntu@${aws_instance.db_instance.public_ip}"
# }