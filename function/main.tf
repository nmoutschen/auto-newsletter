terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.38.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.11.0"
    }
  }
}

provider "docker" {
  registry_auth {
    address  = local.ecr_address
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}

data "aws_caller_identity" "this" {}
data "aws_region" "current" {}
data "aws_ecr_authorization_token" "token" {}

# Lambda function

resource "aws_lambda_function" "this" {
  function_name = var.name
  role = var.role

  package_type = "Image"
  image_uri = local.ecr_image

  memory_size = var.memory_size
  timeout = var.timeout

  depends_on = [
    aws_ecr_repository.this,
    docker_registry_image.this
  ]

  environment {
    variables = var.environment_variables
  }
}

# Container image

locals {
  ecr_address = format("%v.dkr.ecr.%v.amazonaws.com", data.aws_caller_identity.this.account_id, data.aws_region.current.name)
  ecr_image   = format("%v/%v:%v", local.ecr_address, aws_ecr_repository.this.id, var.tag)
}

resource "aws_ecr_repository" "this" {
  name = var.name
}

resource "docker_registry_image" "this" {
  name = local.ecr_image

  build {
    context = var.code
  }
}
