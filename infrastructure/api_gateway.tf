# ---------------------------------------------------------------------------
# API Gateway – REST API
# ---------------------------------------------------------------------------

resource "aws_api_gateway_rest_api" "main" {
  name        = "${var.project_name}-${var.environment}"
  description = "REST API – ${var.project_name} (${var.environment})"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# ---------------------------------------------------------------------------
# Resources: /users, /data, /images
# ---------------------------------------------------------------------------

resource "aws_api_gateway_resource" "users" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "users"
}

resource "aws_api_gateway_resource" "data" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "data"
}

resource "aws_api_gateway_resource" "images" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "images"
}

# ---------------------------------------------------------------------------
# Methods & Integrations – /users (GET + POST)
# ---------------------------------------------------------------------------

resource "aws_api_gateway_method" "users_get" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.users.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "users_get" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.users.id
  http_method             = aws_api_gateway_method.users_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.user_management.invoke_arn
}

resource "aws_api_gateway_method" "users_post" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.users.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "users_post" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.users.id
  http_method             = aws_api_gateway_method.users_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.user_management.invoke_arn
}

# ---------------------------------------------------------------------------
# Methods & Integrations – /data (GET + POST)
# ---------------------------------------------------------------------------

resource "aws_api_gateway_method" "data_get" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.data.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "data_get" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.data.id
  http_method             = aws_api_gateway_method.data_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.data_processing.invoke_arn
}

resource "aws_api_gateway_method" "data_post" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.data.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "data_post" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.data.id
  http_method             = aws_api_gateway_method.data_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.data_processing.invoke_arn
}

# ---------------------------------------------------------------------------
# Methods & Integrations – /images (POST)
# ---------------------------------------------------------------------------

resource "aws_api_gateway_method" "images_post" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.images.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "images_post" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.images.id
  http_method             = aws_api_gateway_method.images_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.image_processing.invoke_arn
}

# ---------------------------------------------------------------------------
# Deployments (one per stage – triggered by API content changes)
# ---------------------------------------------------------------------------

resource "aws_api_gateway_deployment" "dev" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.users,
      aws_api_gateway_resource.data,
      aws_api_gateway_resource.images,
      aws_api_gateway_method.users_get,
      aws_api_gateway_method.users_post,
      aws_api_gateway_method.data_get,
      aws_api_gateway_method.data_post,
      aws_api_gateway_method.images_post,
      aws_api_gateway_integration.users_get,
      aws_api_gateway_integration.users_post,
      aws_api_gateway_integration.data_get,
      aws_api_gateway_integration.data_post,
      aws_api_gateway_integration.images_post,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_deployment" "test" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.users,
      aws_api_gateway_resource.data,
      aws_api_gateway_resource.images,
      aws_api_gateway_method.users_get,
      aws_api_gateway_method.users_post,
      aws_api_gateway_method.data_get,
      aws_api_gateway_method.data_post,
      aws_api_gateway_method.images_post,
      aws_api_gateway_integration.users_get,
      aws_api_gateway_integration.users_post,
      aws_api_gateway_integration.data_get,
      aws_api_gateway_integration.data_post,
      aws_api_gateway_integration.images_post,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_deployment" "prod" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.users,
      aws_api_gateway_resource.data,
      aws_api_gateway_resource.images,
      aws_api_gateway_method.users_get,
      aws_api_gateway_method.users_post,
      aws_api_gateway_method.data_get,
      aws_api_gateway_method.data_post,
      aws_api_gateway_method.images_post,
      aws_api_gateway_integration.users_get,
      aws_api_gateway_integration.users_post,
      aws_api_gateway_integration.data_get,
      aws_api_gateway_integration.data_post,
      aws_api_gateway_integration.images_post,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------
# Stages – dev (no cache), test (no cache), prod (cache enabled)
# ---------------------------------------------------------------------------

locals {
  access_log_format = jsonencode({
    requestId      = "$context.requestId"
    ip             = "$context.identity.sourceIp"
    caller         = "$context.identity.caller"
    user           = "$context.identity.user"
    requestTime    = "$context.requestTime"
    httpMethod     = "$context.httpMethod"
    resourcePath   = "$context.resourcePath"
    status         = "$context.status"
    protocol       = "$context.protocol"
    responseLength = "$context.responseLength"
  })
}

resource "aws_api_gateway_stage" "dev" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  deployment_id = aws_api_gateway_deployment.dev.id
  stage_name    = "dev"

  cache_cluster_enabled = false

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format          = local.access_log_format
  }
}

resource "aws_api_gateway_stage" "test" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  deployment_id = aws_api_gateway_deployment.test.id
  stage_name    = "test"

  cache_cluster_enabled = false

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format          = local.access_log_format
  }
}

resource "aws_api_gateway_stage" "prod" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  deployment_id = aws_api_gateway_deployment.prod.id
  stage_name    = "prod"

  cache_cluster_enabled = true
  cache_cluster_size    = var.api_cache_size

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format          = local.access_log_format
  }
}

# ---------------------------------------------------------------------------
# Method settings – enable caching on all methods in prod
# ---------------------------------------------------------------------------

resource "aws_api_gateway_method_settings" "prod_cache" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = aws_api_gateway_stage.prod.stage_name
  method_path = "*/*"

  settings {
    caching_enabled      = true
    cache_ttl_in_seconds = var.api_cache_ttl
    cache_data_encrypted = true
    metrics_enabled      = true
    logging_level        = "INFO"
  }
}

# ---------------------------------------------------------------------------
# Lambda permissions – allow API Gateway to invoke each function
# ---------------------------------------------------------------------------

resource "aws_lambda_permission" "users" {
  statement_id  = "AllowAPIGatewayInvokeUsers"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.user_management.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "data" {
  statement_id  = "AllowAPIGatewayInvokeData"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.data_processing.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "images" {
  statement_id  = "AllowAPIGatewayInvokeImages"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.image_processing.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

# ---------------------------------------------------------------------------
# CloudWatch – API Gateway access log group
# ---------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${var.project_name}-${var.environment}"
  retention_in_days = var.log_retention_days
}
