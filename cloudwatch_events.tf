resource "aws_cloudwatch_event_rule" "raw_bucket_objects" {
  name        = "capture-objects-created"
  description = "Capture S3 Objects Created"
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

resource "aws_cloudwatch_event_target" "step_function" {
  rule      = aws_cloudwatch_event_rule.raw_bucket_objects.name
  target_id = "StepFunctionTrigger"
  arn       = aws_sfn_state_machine.sfn_state_machine.arn
  role_arn  = aws_iam_role.events.arn
}