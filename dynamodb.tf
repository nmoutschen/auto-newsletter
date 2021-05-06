resource "aws_dynamodb_table" "this" {
  name = "${var.prefix}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "pk"
  range_key = "sk"

  attribute {
    name = "pk"
    type = "S"
  }

  attribute {
    name = "sk"
    type = "S"
  }
}

# Test data
resource "aws_dynamodb_table_item" "serverlessland" {
  table_name = aws_dynamodb_table.this.id
  hash_key = aws_dynamodb_table.this.hash_key
  range_key = aws_dynamodb_table.this.range_key

  item = <<EOF
{
  "pk": {"S": "feed"},
  "sk": {"S": "https://serverlessland.com/feed.xml"},
  "timestamp": {"N": "0"}
}
EOF
}