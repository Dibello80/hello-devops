
resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = data.aws_security_group.existing.id

  description = "Allow HTTPS traffic to Nginx"
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_ipv4   = "0.0.0.0/0"

  tags = {
    Name = "hello-devops-https"
  }
}
