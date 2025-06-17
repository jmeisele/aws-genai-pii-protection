resource "aws_lambda_function" "macie_scan" {
  function_name    = "macie_scan"
  description      = "Copies file over to scan bucket and initiates Macie scan"
  filename         = data.archive_file.macie_scan.output_path
  source_code_hash = data.archive_file.macie_scan.output_base64sha256
  role             = aws_iam_role.lambda_macie.arn
  runtime          = "python3.12"
  handler          = "macie_scan_trigger.lambda_handler"
  timeout          = 600
  depends_on = [
    aws_cloudwatch_log_group.macie_scan
  ]
  environment {
    variables = {
      RAW_BUCKET  = aws_s3_bucket.raw.bucket
      SCAN_BUCKET = aws_s3_bucket.scan.bucket
      AWS_ACCOUNT = var.account_id
    }
  }
  logging_config {
    log_format = "JSON"
  }
}

resource "aws_lambda_permission" "allow_raw_bucket" {
  statement_id  = "AllowExecutionFromRaw3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.macie_scan.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.raw.arn
}