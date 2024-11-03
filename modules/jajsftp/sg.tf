resource "aws_security_group" "jajsftp_sg" {
  name        = "jajsftp_${var.name}"
  description = "Security Group for JAJSFTP Server"
}

resource "aws_security_group_rule" "jajsftp_sg_http" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.jajsftp_sg.id
}

resource "aws_security_group_rule" "jajsftp_sg_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.jajsftp_sg.id
}

resource "aws_security_group_rule" "jajsftp_sg_admin" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = formatlist("%s/32", var.admin_whitelist)
  security_group_id = aws_security_group.jajsftp_sg.id
}
