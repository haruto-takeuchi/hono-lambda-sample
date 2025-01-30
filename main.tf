terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.82"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = local.aws_region
}

locals {
  aws_region = "ap-northeast-1"
}

# Lambda Function
resource "aws_lambda_function" "hono-app" {
    function_name = "hono-app-lambda"
    filename = "./lambda.zip"
    source_code_hash = filebase64sha256("./lambda.zip")
    role = aws_iam_role.iam_for_hono_lambda.arn

    handler = "index.handler"
    runtime = "nodejs22.x"

    environment {
      variables = {
        NODE_ENV = "production"
        PORT = "3000"
      }
    }
}

# Lambda Function URL
resource "aws_lambda_function_url" "hono-function-url" {
  function_name      = aws_lambda_function.hono-app.function_name
  authorization_type = "AWS_IAM"
}

data "aws_iam_policy_document" "assume_role" {
    statement {
      effect = "Allow"
      actions = [ "sts:AssumeRole" ]
      principals {
        type = "Service"
        identifiers = [ "lambda.amazonaws.com" ]
      }
    }
}

resource "aws_iam_role" "iam_for_hono_lambda" {
    name = "iam-for-hono-lambda"
    assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# TODO: API Gateway
