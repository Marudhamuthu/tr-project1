output "instance_id" {
  description = "The ID of the Jenkins server instance."
  value       = aws_instance.jenkins.id
}

output "public_ip" {
  description = "The public IP of the Jenkins server."
  value       = aws_eip.jenkins_eip.public_ip
}
output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.vpc.id
}

output "subnet_ids" {
  description = "The IDs of the subnets."
  value       = aws_subnet.public-subnet.id
}
