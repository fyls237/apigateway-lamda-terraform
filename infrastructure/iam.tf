# ---------------------------------------------------------------------------
# IAM – Reference the existing LabRole for Lambda execution
# ---------------------------------------------------------------------------

# Use the existing LabRole from AWS Academy
data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

# Reference the lab role for Lambda execution
locals {
  lambda_exec_role_arn = data.aws_iam_role.lab_role.arn
}
