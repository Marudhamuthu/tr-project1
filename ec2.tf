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
  user_data = <<EOF
#!/bin/bash
# Update package lists
sudo apt-get update -y

# Install docker.io and git
sudo apt-get install -y docker.io git

# Start and enable the Docker service
sudo systemctl start docker
wsudo systemctl enable docker

# Format and mount the EBS volume
if ! file -s /dev/nvme1n1 | grep ext4; then
mkfs.ext4 /dev/nvme1n1
fi
mkdir -p /data/jenkins_home
mount /dev/nvme1n1 /data/jenkins_home
chown -R ubuntu:ubuntu /data/jenkins_home

# Add volume to /etc/fstab for persistence after reboot
echo '/dev/nvme1n1 /data/jenkins_home ext4 defaults,nofail 0 2' >> /etc/fstab

# Install Docker Compose
apt-get install docker-compose -y

# Clone the Docker Compose repository
git clone ${var.docker_compose_repo} /home/ubuntu/jenkins

# Run Docker Compose in detached mode
sudo docker-compose -f /home/ubuntu/jenkins/docker-compose.yml up -d

# Exit on any command failure (optional)
set -e
EOF
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

