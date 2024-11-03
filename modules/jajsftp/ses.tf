resource "aws_ses_email_identity" "jajsftp_email_admin" {
  email = var.admin_email
}
