output "api_gateway_id" {
  description = "ID of the REST API Gateway"
  value       = aws_api_gateway_rest_api.main.id
}

output "api_url_dev" {
  description = "Invoke URL for the dev stage"
  value       = aws_api_gateway_stage.dev.invoke_url
}

output "api_url_test" {
  description = "Invoke URL for the test stage"
  value       = aws_api_gateway_stage.test.invoke_url
}

output "api_url_prod" {
  description = "Invoke URL for the prod stage"
  value       = aws_api_gateway_stage.prod.invoke_url
}

output "lambda_user_management_arn" {
  description = "ARN of the user_management Lambda function"
  value       = aws_lambda_function.user_management.arn
}

output "lambda_data_processing_arn" {
  description = "ARN of the data_processing Lambda function"
  value       = aws_lambda_function.data_processing.arn
}

output "lambda_image_processing_arn" {
  description = "ARN of the image_processing Lambda function"
  value       = aws_lambda_function.image_processing.arn
}
