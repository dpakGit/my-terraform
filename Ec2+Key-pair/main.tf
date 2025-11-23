# This code creates an EC2 instance with the specified key pair, security group, and outputs the instance IP and SSH command.

provider "aws" {
  region = "us-east-1" # Change to your desired AWS region
}

resource "tls_private_key" "devops_kp" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "devops_kp" {
  key_name   = "devops-kp"
  public_key = tls_private_key.devops_kp.public_key_openssh
}

resource "local_file" "devops_kp_pem" {
  content         = tls_private_key.devops_kp.private_key_pem
  filename        = "/home/bob/devops-kp.pem"
  file_permission = "0600"
}

resource "aws_security_group" "example" {
  name        = "example-sg"
  description = "Example security group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "example" {
  ami           = "ami-0c2ab3b8ef8415e85" # Change to your desired AMI
  instance_type = "t2.micro"
  key_name      = aws_key_pair.devops_kp.key_name
  vpc_security_group_ids = [aws_security_group.example.id]

  tags = {
    Name = "example-instance"
  }
}

output "instance_ip" {
  value = aws_instance.example.public_ip
}

output "ssh_command" {
  value = "ssh -i /home/bob/devops-kp.pem ec2-user@${aws_instance.example.public_ip}"
}


