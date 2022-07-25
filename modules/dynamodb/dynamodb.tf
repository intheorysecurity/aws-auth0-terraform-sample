//dynamodb table example

resource "aws_dynamodb_table" "users_table" {
  name           = "sample-users-table"
  hash_key       = "id"
  read_capacity  = 5
  write_capacity = 5

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "username"
    type = "S"
  }


  global_secondary_index {
    name               = "usernameIndex"
    hash_key           = "username"
    write_capacity     = 5
    read_capacity      = 5
    projection_type    = "INCLUDE"
    non_key_attributes = ["id"]
  }
  tags = {
    Name        = "sample-users-table"
    Environment = "POC"
  }
}

output "dynamodb_users_table_arn" {
  value = aws_dynamodb_table.users_table.arn
}