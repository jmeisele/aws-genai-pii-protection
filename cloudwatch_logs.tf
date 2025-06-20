resource "aws_cloudwatch_log_group" "macie_scan" {
  name              = "/aws/lambda/macie_scan"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "macie_status" {
  name              = "/aws/lambda/macie_status"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "macie_findings" {
  name              = "/aws/lambda/macie_findings"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "macie_xfer_clean" {
  name              = "/aws/lambda/macie_xfer_clean"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "macie_xfer_sensitive" {
  name              = "/aws/lambda/macie_xfer_sensitive"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "step_function_id" {
  name              = "/aws/lambda/step_function_stdout"
  retention_in_days = 7
}

# resource "aws_cloudwatch_metric_alarm" "macie_scan" {
#   alarm_name          = "macie_scan-lambda-error"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = "1"
#   metric_name         = "Errors"
#   namespace           = "AWS/Lambda"
#   period              = "60"
#   statistic           = "Maximum"
#   threshold           = 1
#   alarm_description   = "Lambda Errored Out"

#   alarm_actions = [
#     "${aws_sns_topic.macie_scan.arn}",
#   ]

#   dimensions = {
#     FunctionName = aws_lambda_function.macie_scan.function_name
#   }
# }