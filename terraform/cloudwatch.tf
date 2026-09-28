resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "hello-devops-high-cpu"
  alarm_description   = "Alert when EC2 CPU exceeds 70 percent for 10 minutes"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  treat_missing_data  = "missing"

  dimensions = {
    InstanceId = aws_instance.hello_devops.id
  }

  alarm_actions             = []
  ok_actions                = []
  insufficient_data_actions = []

  tags = {
    Project = "hello-devops"
  }
}