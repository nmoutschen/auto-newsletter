# get_feed_urls

resource "aws_iam_role" "get_feed_urls" {
  name = "${var.prefix}-get-feed-urls"

  assume_role_policy = data.aws_iam_policy_document.get_feed_urls_assume.json
  inline_policy {
    name   = "FunctionPolicy"
    policy = data.aws_iam_policy_document.get_feed_urls.json
  }

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
}

data "aws_iam_policy_document" "get_feed_urls_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type       = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "get_feed_urls" {
  statement {
    actions = ["dynamodb:query"]
    resources = [aws_dynamodb_table.this.arn]
  }
}

module "get_feed_urls" {
  source = "./function"

  name = "${var.prefix}-get-feed-urls"
  role = aws_iam_role.get_feed_urls.arn

  code = "src/get_feed_urls"
  tag = "1.0.0"

  environment_variables = {
    TABLE_NAME = aws_dynamodb_table.this.id
  }
}

# fetch_articles

resource "aws_iam_role" "fetch_articles" {
  name = "${var.prefix}-fetch-articles"

  assume_role_policy = data.aws_iam_policy_document.fetch_articles_assume.json
  inline_policy {
    name   = "FunctionPolicy"
    policy = data.aws_iam_policy_document.fetch_articles.json
  }

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
}

data "aws_iam_policy_document" "fetch_articles_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type       = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "fetch_articles" {
  statement {
    actions = ["dynamodb:BatchWriteItem"]
    resources = [aws_dynamodb_table.this.arn]
  }
}

module "fetch_articles" {
  source = "./function"

  name = "${var.prefix}-fetch-articles"
  role = aws_iam_role.fetch_articles.arn

  timeout = 30

  code = "src/fetch_articles"
  tag = "1.0.1"

  environment_variables = {
    TABLE_NAME = aws_dynamodb_table.this.id
  }
}