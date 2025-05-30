# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

resource "aws_instance" "bastion_linux" {
  user_data                   = filebase64("${path.module}/user_data_script/user-data-bastion.sh")
  iam_instance_profile        = aws_iam_instance_profile.bastion_instance_profile.name
  ami                         = data.aws_ssm_parameter.amazon_linux.value
  instance_type               = var.ec2_instance_type
  tenancy                     = "default"
  ebs_optimized               = true
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  associate_public_ip_address = false
  monitoring                  = true
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  root_block_device {
    volume_size           = 30
    delete_on_termination = true
    encrypted             = true
    kms_key_id            = data.aws_ebs_default_kms_key.current.key_arn
  }
  tags = merge(
    { Name = "ec2-${var.identifier}-bastion" },
    var.tags
  )
  lifecycle {
    ignore_changes = [
      user_data,
      root_block_device[0].kms_key_id,
      ami
    ]
  }
}

resource "aws_security_group" "bastion" {
  #checkov:skip=CKV_AWS_382:This SG is for network testing purposes and must allow egress communication to 0.0.0.0/0.
  name_prefix = "ec2-bastion-sgp-"
  description = "Access to bastion instance: allow SSH and ICMP access from appropriate location. Allow all traffic from VPC CIDR"
  vpc_id      = var.vpc_id
  ingress {
    cidr_blocks = var.test_network_cidr
    description = "Allow SSH from test network"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = var.test_network_cidr
    description = "Allow ICMP from test network"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
  }
  ingress {
    cidr_blocks = data.aws_vpc.this.cidr_block_associations[*].cidr_block
    description = "Allow ALL traffic from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "all"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow ALL egress traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
  tags = merge(
    { "Name" = "ec2-${var.identifier}-bastion-sgp" },
    var.tags
  )
  lifecycle {
    # Necessary if changing 'name' or 'name_prefix' properties.
    create_before_destroy = true
  }
}

resource "aws_iam_role" "bastion_role" {
  name_prefix           = "ec2-${var.identifier}-bastion-role-"
  force_detach_policies = true
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action = "sts:AssumeRole"
          Principal = {
            Service = "ec2.amazonaws.com"
          }
          Effect = "Allow"
          Sid    = ""
        }
      ]
    }
  )
  tags = var.tags
}

resource "aws_iam_role_policy_attachments_exclusive" "bastion_role" {
  role_name   = aws_iam_role.bastion_role.name
  policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
}

resource "aws_iam_instance_profile" "bastion_instance_profile" {
  name_prefix = "ec2-${var.identifier}-bastion-instance-profile-"
  role        = aws_iam_role.bastion_role.name
}
