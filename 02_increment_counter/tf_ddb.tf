resource "aws_dynamodb_table" "incrementation" {
  name           = "incrementation"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "CountName"

  attribute {
    name = "CountName"
    type = "S"
  }

  //  attribute {
  //    name = "CountValue"
  //    type = "S"
  //  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }
  tags {
    Name  = "incrementation"
    Owner = "jprice"
  }
}