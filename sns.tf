resource "aws_sns_topic" "macie_scan" {
  name = "macie_scan_failure_topic"
}

resource "aws_sns_topic_subscription" "macie_scan" {
  topic_arn = aws_sns_topic.macie_scan.arn
  protocol  = "email"
  endpoint  = "jmeisele@yahoo.com"
}