resource "aws_cloudwatch_log_group" "macie_scan" {
  name              = "/aws/lambda/macie_scan"
  retention_in_days = 7
}

resource "aws_cloudwatch_metric_alarm" "macie_scan" {
  alarm_name          = "macie_scan-lambda-error"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Maximum"
  threshold           = 1
  alarm_description   = "Lambda Errored Out"

  alarm_actions = [
    "${aws_sns_topic.macie_scan.arn}",
  ]

  dimensions = {
    FunctionName = aws_lambda_function.macie_scan.function_name
  }
}