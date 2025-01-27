variable "vpc-name" {}
variable "igw-name" {}
variable "rt-name" {}
variable "subnet-name" {}
variable "sg-name" {}
variable "instance-name" {}
variable "key-name" {}
variable "iam-role" {}
variable "docker_compose_repo" {
  description = "The GitHub repository URL containing the Docker Compose file for Jenkins."
  type        = string
}
