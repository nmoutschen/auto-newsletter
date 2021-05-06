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
  tag = "1.1"

  environment_variables = {
    TABLE_NAME = aws_dynamodb_table.this.id
  }
}