# resource "aws_sfn_state_machine" "sfn_state_machine" {
#   name     = "pii-macie-scanner-state-machine"
#   role_arn = aws_iam_role.step.arn

#   definition = file("${path.module}/state_machine.asl.json")
# }