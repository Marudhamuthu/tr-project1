resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.ami.image_id
  instance_type          = "t3.medium"
  key_name               = var.key-name
  subnet_id              = aws_subnet.public-subnet.id
  vpc_security_group_ids = [aws_security_group.security-group.id]
  iam_instance_profile   = aws_iam_instance_profile.instance-profile.name
  associate_public_ip_address = true
  
  tags = {
    Name = var.instance-name
  }
   provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y docker.io git",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "git clone ${var.docker_compose_repo} /home/ubuntu/jenkins",
      "sudo docker-compose -f /home/ubuntu/jenkins/docker-compose.yml up -d"
    ]
  }
}

resource "aws_ebs_volume" "jenkins_data" {
  availability_zone = aws_instance.jenkins.availability_zone
  size              = var.ebs_volume_size

  tags = {
    Name = "Jenkins Data Volume"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.jenkins_data.id
  instance_id = aws_instance.jenkins.id
}

resource "aws_eip" "jenkins_eip" {
  instance = aws_instance.jenkins.id
  vpc      = true
}

resource "aws_backup_plan" "jenkins_backup" {
  name = "jenkins-backup-plan"

  rule {
    rule_name         = "daily-ebs-backup"
    target_vault_name = aws_backup_vault.jenkins_vault.name
    schedule          = var.snapshot_schedule
    lifecycle {
      delete_after = 30
    }
  }
}

resource "aws_backup_vault" "jenkins_vault" {
  name = "jenkins-backup-vault"
}

output "instance_id" {
  description = "The ID of the Jenkins server instance."
  value       = aws_instance.jenkins.id
}

output "public_ip" {
  description = "The public IP of the Jenkins server."
  value       = aws_eip.jenkins_eip.public_ip
}
