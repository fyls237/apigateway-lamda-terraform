terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }

  backend "s3" {
    # Configure via -backend-config flags or environment variables:
    #   bucket         = var.TF_STATE_BUCKET
    #   key            = "apigateway-lambda/terraform.tfstate"
    #   region         = var.aws_region
    #   dynamodb_table = var.TF_STATE_LOCK_TABLE
    #   encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  }
}
