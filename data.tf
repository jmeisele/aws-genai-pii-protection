data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "assume_step_functions" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "assume_lambda" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "assume_role_events" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "lambda_macie" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
  statement {
    actions   = ["macie2:*"]
    resources = ["*"]
  }
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads"
    ]
    resources = [
      aws_s3_bucket.raw.arn,
      aws_s3_bucket.scan.arn,
      aws_s3_bucket.sensitive.arn,
      aws_s3_bucket.clean.arn
    ]
  }
  statement {
    sid    = "BucketObjects"
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:GetObjectTagging",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionTagging",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
      "s3:PutObjectTagging"
    ]
    resources = [
      "${aws_s3_bucket.raw.arn}/*",
      "${aws_s3_bucket.scan.arn}/*",
      "${aws_s3_bucket.sensitive.arn}/*",
      "${aws_s3_bucket.clean.arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "step" {
  statement {
    actions = [
      "lambda:InvokeFunction",
    ]
    resources = [
      aws_lambda_function.step_function_id.arn,
      aws_lambda_function.macie_scan.arn,
      aws_lambda_function.macie_status.arn,
      aws_lambda_function.macie_findings.arn,
      aws_lambda_function.macie_xfer_clean.arn,
      aws_lambda_function.macie_xfer_sensitive.arn
    ]
  }
}

data "aws_iam_policy_document" "step_function_execute" {
  statement {
    actions = [
      "states:StartExecution",
    ]
    resources = [
      aws_sfn_state_machine.sfn_state_machine.arn
    ]
  }
}

data "archive_file" "macie_scan" {
  type        = "zip"
  source_file = "${path.module}/src/macie_scan_trigger.py"
  output_path = "macie_scan.zip"
}

data "archive_file" "macie_status" {
  type        = "zip"
  source_file = "${path.module}/src/macie_status_check.py"
  output_path = "macie_status.zip"
}

data "archive_file" "macie_findings" {
  type        = "zip"
  source_file = "${path.module}/src/macie_findings_count.py"
  output_path = "macie_findings.zip"
}

data "archive_file" "macie_xfer_clean" {
  type        = "zip"
  source_file = "${path.module}/src/transfer_clean_files.py"
  output_path = "macie_xfer_clean.zip"
}

data "archive_file" "macie_xfer_sensitive" {
  type        = "zip"
  source_file = "${path.module}/src/transfer_sensitive_files.py"
  output_path = "macie_xfer_sensitive.zip"
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/src/lambda.py"
  output_path = "lambda.zip"
}