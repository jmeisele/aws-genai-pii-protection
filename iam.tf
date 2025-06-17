resource "aws_iam_role" "lambda_macie" {
  name               = "lambda_macie"
  assume_role_policy = data.aws_iam_policy_document.assume_lambda.json
}

resource "aws_iam_policy" "lambda_macie" {
  name        = "lambda_s3_macie_scan"
  description = "Policies to copy objects and use Macie"
  policy      = data.aws_iam_policy_document.lambda_macie.json
}

resource "aws_iam_role_policy_attachment" "lambda_macie" {
  role       = aws_iam_role.lambda_macie.name
  policy_arn = aws_iam_policy.lambda_macie.arn
}

resource "aws_iam_role" "step" {
  name               = "step_functions"
  assume_role_policy = data.aws_iam_policy_document.assume_step_functions.json
}

resource "aws_iam_policy" "step" {
  name        = "step_functions_policy"
  description = "Step functions policy"
  policy      = data.aws_iam_policy_document.step.json
}

resource "aws_iam_role_policy_attachment" "step" {
  role       = aws_iam_role.step.name
  policy_arn = aws_iam_policy.step.arn
}