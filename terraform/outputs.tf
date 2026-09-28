output "ec2_instance_id" {
  description = "ID of the existing EC2 instance"
  value       = aws_instance.hello_devops.id
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.hello_devops.public_ip
}

output "vpc_id" {
  description = "ID of the existing VPC"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "ID of the existing subnet"
  value       = data.aws_subnet.existing.id
}