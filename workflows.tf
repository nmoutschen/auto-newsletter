resource "aws_iam_role" "processor" {
  name = "${var.prefix}-processor"

  assume_role_policy = data.aws_iam_policy_document.processor_assume.json
  inline_policy {
    name   = "ProcessorPolicy"
    policy = data.aws_iam_policy_document.processor.json
  }
}

data "aws_iam_policy_document" "processor_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type       = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "processor" {
  statement {
    actions = ["lambda:InvokeFunction"]
    resources = [
      module.get_feed_urls.arn,
      module.fetch_articles.arn
    ]
  }
}

resource "aws_sfn_state_machine" "processor" {
  name     = "${var.prefix}-processor"
  role_arn = aws_iam_role.processor.arn

  definition = templatefile("resources/processor.asl.json", {
    get_feed_urls = module.get_feed_urls.arn
    fetch_articles = module.fetch_articles.arn
  })
}