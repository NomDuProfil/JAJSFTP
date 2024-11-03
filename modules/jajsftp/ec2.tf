data "aws_ami" "jajsftp_last_linux_image" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

resource "aws_instance" "jajsftp_instance" {
  ami           = data.aws_ami.jajsftp_last_linux_image.image_id
  instance_type = "t4g.nano"
  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }
  iam_instance_profile = aws_iam_instance_profile.jajsftp_ec2_instance_profile.name

  user_data = templatefile("${path.module}/install_script.sh.tpl", {
    s3_name        = aws_s3_bucket.jajsftp_s3_bucket.bucket,
    admin_username = var.admin_username,
    admin_email    = var.admin_email,
    aws_region     = data.aws_region.aws_region_information.name
  })

  tags = {
    Name = var.name
  }

  vpc_security_group_ids = [aws_security_group.jajsftp_sg.id]

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  lifecycle {
    ignore_changes = [ami]
  }
}
