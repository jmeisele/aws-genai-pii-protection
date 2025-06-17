resource "aws_s3_bucket" "raw" {
  bucket_prefix = "raw"
  force_destroy = true
}

resource "aws_s3_bucket" "scan" {
  bucket_prefix = "scan"
  force_destroy = true
}

resource "aws_s3_bucket" "sensitive" {
  bucket_prefix = "sensitive"
  force_destroy = true
}

resource "aws_s3_bucket" "clean" {
  bucket_prefix = "clean"
  force_destroy = true
}

# resource "aws_s3_object" "txt_file" {
#   bucket = aws_s3_bucket.raw.bucket
#   key    = "foo.txt"
#   source = "./foo.txt"
# }

# resource "aws_s3_bucket_notification" "raw_bucket_notification" {
#   bucket = aws_s3_bucket.raw.id

#   lambda_function {
#     lambda_function_arn = aws_lambda_function.macie_scan.arn
#     events              = ["s3:ObjectCreated:*"]
#   }
#   depends_on = [aws_lambda_permission.allow_raw_bucket]
# }

resource "aws_s3_bucket_notification" "raw_bucket_notification" {
  bucket      = aws_s3_bucket.raw.id
  eventbridge = true
}

resource "aws_cloudwatch_event_rule" "raw_bucket_objects" {
  name        = "capture-objects-created"
  description = "Capture each AWS Console Sign In"
  # {
  #   "source": ["aws.s3"],
  #   "detail-type": ["Object Created"],
  #   "detail": {
  #     "bucket": {
  #       "name": ["raw20250617121549564000000004 "]
  #     }
  #   }
  # }

  event_pattern = jsonencode({
    source = ["aws.s3"]
    detail = {
      bucket = {
        name = [aws_s3_bucket.raw.bucket]
      }
    }
    detail-type = [
      "Object Created"
    ]
  })
}

# resource "aws_cloudwatch_event_target" "sns" {
#   rule      = aws_cloudwatch_event_rule.console.name
#   target_id = "SendToSNS"
#   arn       = aws_sns_topic.aws_logins.arn
# }