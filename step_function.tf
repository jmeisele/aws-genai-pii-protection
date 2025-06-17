resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "pii-macie-scanner-state-machine"
  role_arn = aws_iam_role.step.arn

  # definition = templatefile(
  #   "${path.module}/state_machine.asl.json",
  #   {
  #     number_generator = aws_lambda_function.number_generator.arn
  #     even             = aws_lambda_function.even.arn
  #     odd              = aws_lambda_function.odd.arn
  #   }
  # )

  definition = file("${path.module}/state_machine.asl.json")
}