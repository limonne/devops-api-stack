resource "aws_dynamodb_table" "terraform" {
  name         = var.name
  hash_key     = "ID"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "ID"
    type = "S"
  }

  tags = {
    name = var.name
  }
}
