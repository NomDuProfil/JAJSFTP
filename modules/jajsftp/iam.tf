data "aws_iam_policy_document" "jajsftp_s3_ses_policy" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "${aws_s3_bucket.jajsftp_s3_bucket.arn}",
      "${aws_s3_bucket.jajsftp_s3_bucket.arn}/*"
    ]
  }

  statement {
    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail"
    ]
    resources = ["arn:aws:ses:${data.aws_region.aws_region_information.name}:${data.aws_caller_identity.aws_information.account_id}:identity/${aws_ses_email_identity.jajsftp_email_admin.email}"]
  }

  statement {
    actions = [
      "ses:GetIdentityVerificationAttributes"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "jajsftp_ec2_role" {
  name = "jajsftp_${var.name}_ec2_s3_ses_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "jajsftp_s3_ses_policy" {
  name   = "jajsftp_${var.name}_s3_ses_policy"
  role   = aws_iam_role.jajsftp_ec2_role.id
  policy = data.aws_iam_policy_document.jajsftp_s3_ses_policy.json
}

resource "aws_iam_policy_attachment" "jajsftp_ssm_role_attach" {
  name       = "jajsftp_${var.name}_ssm_role_attach"
  roles      = [aws_iam_role.jajsftp_ec2_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "jajsftp_ec2_instance_profile" {
  name = "jajsftp_${var.name}_ec2_instance_profile"
  role = aws_iam_role.jajsftp_ec2_role.name
}
