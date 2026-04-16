# ---------------------------------------------------------------------------
# Lambda – Archive sources
# ---------------------------------------------------------------------------

data "archive_file" "user_management" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/user_management"
  output_path = "${path.module}/../lambda/user_management.zip"
}

data "archive_file" "data_processing" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/data_processing"
  output_path = "${path.module}/../lambda/data_processing.zip"
}

data "archive_file" "image_processing" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/image_processing"
  output_path = "${path.module}/../lambda/image_processing.zip"
}

# ---------------------------------------------------------------------------
# Lambda – Functions
# ---------------------------------------------------------------------------

resource "aws_lambda_function" "user_management" {
  function_name    = "${var.project_name}-user-management-${var.environment}"
  filename         = data.archive_file.user_management.output_path
  source_code_hash = data.archive_file.user_management.output_base64sha256
  role             = local.lambda_exec_role_arn
  handler          = "index.handler"
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size

  environment {
    variables = {
      ENVIRONMENT = var.environment
    }
  }
}

resource "aws_lambda_function" "data_processing" {
  function_name    = "${var.project_name}-data-processing-${var.environment}"
  filename         = data.archive_file.data_processing.output_path
  source_code_hash = data.archive_file.data_processing.output_base64sha256
  role             = local.lambda_exec_role_arn
  handler          = "index.handler"
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size

  environment {
    variables = {
      ENVIRONMENT = var.environment
    }
  }
}

resource "aws_lambda_function" "image_processing" {
  function_name    = "${var.project_name}-image-processing-${var.environment}"
  filename         = data.archive_file.image_processing.output_path
  source_code_hash = data.archive_file.image_processing.output_base64sha256
  role             = local.lambda_exec_role_arn
  handler          = "index.handler"
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size

  environment {
    variables = {
      ENVIRONMENT = var.environment
    }
  }
}

# ---------------------------------------------------------------------------
# CloudWatch – Log groups (one per function)
# NOTE: Commented out due to permission restrictions in AWS Academy Lab
# Lambda functions will automatically create log groups on first execution
# ---------------------------------------------------------------------------
# resource "aws_cloudwatch_log_group" "user_management" {
#   name              = "/aws/lambda/${aws_lambda_function.user_management.function_name}"
#   retention_in_days = var.log_retention_days
# }
#
# resource "aws_cloudwatch_log_group" "data_processing" {
#   name              = "/aws/lambda/${aws_lambda_function.data_processing.function_name}"
#   retention_in_days = var.log_retention_days
# }
#
# resource "aws_cloudwatch_log_group" "image_processing" {
#   name              = "/aws/lambda/${aws_lambda_function.image_processing.function_name}"
#   retention_in_days = var.log_retention_days
# }
