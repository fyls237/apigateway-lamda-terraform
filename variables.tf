variable "aws_region" {
  description = "AWS region where resources will be deployed"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Prefix used for naming all AWS resources"
  type        = string
  default     = "apigateway-lambda"
}

variable "environment" {
  description = "Active deployment environment (dev | test | prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment must be one of: dev, test, prod."
  }
}

variable "lambda_runtime" {
  description = "AWS Lambda runtime for all functions"
  type        = string
  default     = "nodejs18.x"
}

variable "lambda_timeout" {
  description = "Maximum execution time for Lambda functions (seconds)"
  type        = number
  default     = 30
}

variable "lambda_memory_size" {
  description = "Memory allocated to each Lambda function (MB)"
  type        = number
  default     = 128
}

variable "api_cache_size" {
  description = "API Gateway cache cluster size in GB (only used in prod stage)"
  type        = string
  default     = "0.5"

  validation {
    condition     = contains(["0.5", "1.6", "6.1", "13.5", "28.4", "58.2", "118", "237"], var.api_cache_size)
    error_message = "api_cache_size must be a valid API Gateway cache size value."
  }
}

variable "api_cache_ttl" {
  description = "Default cache TTL in seconds for API Gateway method settings"
  type        = number
  default     = 300
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch log groups"
  type        = number
  default     = 14
}
