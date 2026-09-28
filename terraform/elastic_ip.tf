
resource "aws_eip" "hello_devops" {
  domain   = "vpc"
  instance = aws_instance.hello_devops.id
}
