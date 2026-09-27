terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_ssm_parameter" "ubuntu_ami" {
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

resource "aws_iam_role" "coolify" {
  name = "${var.name}-instance-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.coolify.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "coolify" {
  name = "${var.name}-instance-profile"
  role = aws_iam_role.coolify.name
}

resource "aws_security_group" "coolify" {
  name        = "${var.name}-sg"
  description = "Public HTTPS for iQuash OCR/Coolify; admin access uses AWS SSM"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = var.name
    App  = "iquash"
  }
}

resource "aws_instance" "coolify" {
  ami                    = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.coolify.id]
  iam_instance_profile   = aws_iam_instance_profile.coolify.name

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_gb
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  user_data = <<-CLOUDINIT
    #!/usr/bin/env bash
    set -euxo pipefail
    apt-get update
    apt-get install -y git curl ca-certificates
    mkdir -p /opt/dnawebai
    if [ ! -d /opt/dnawebai/coolify/.git ]; then
      git clone --depth 1 https://github.com/dnawebai/coolify.git /opt/dnawebai/coolify
    fi
    chmod +x /opt/dnawebai/coolify/scripts/install.sh
    /opt/dnawebai/coolify/scripts/install.sh
  CLOUDINIT

  tags = {
    Name = var.name
    App  = "iquash"
    Role = "coolify-ocr-host"
  }
}

resource "aws_eip" "coolify" {
  domain   = "vpc"
  instance = aws_instance.coolify.id
  tags = {
    Name = "${var.name}-eip"
    App  = "iquash"
  }
}
