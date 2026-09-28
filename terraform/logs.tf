resource "aws_cloudwatch_log_group" "application" {
  name              = "/hello-devops/application"
  retention_in_days = 7

  tags = {
    Project = "hello-devops"
  }
}