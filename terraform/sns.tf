
resource "aws_sns_topic" "devops_alerts" {
  name = "hello-devops-alerts"

  tags = {
    Project = "hello-devops"
  }
}

data "aws_iam_policy_document" "sns_alarm_policy" {
  statement {
    sid    = "AllowCloudWatchAlarmPublish"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }

    actions = [
      "SNS:Publish"
    ]

    resources = [
      aws_sns_topic.devops_alerts.arn
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = ["200359303675"]
    }
  }
}

resource "aws_sns_topic_policy" "devops_alerts" {
  arn    = aws_sns_topic.devops_alerts.arn
  policy = data.aws_iam_policy_document.sns_alarm_policy.json
}
