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
variable "ebs_volume_size" {
  description = "The size of the EBS volume for Jenkins data persistence."
  type        = number
}

variable "elastic_ip" {
  description = "The Elastic IP to associate with the Jenkins server."
  type        = string
}

variable "snapshot_schedule" {
  description = "The cron expression for the EBS snapshot schedule."
  type        = string
}
