# Create a DynamoDB table.
resource "aws_dynamodb_table" "incrementation" {
  name           = "incrementation"
  read_capacity  = 1                # TODO: if you're using this for real, this is too small
  write_capacity = 1
  hash_key       = "CountName"

  attribute {
    name = "CountName"
    type = "S"
  }

  # You're not allowed to specify attributes which are not used as hash_key or range_key, but I like to
  # document them anyway.  This will be a json blob of `{"count": <int>}`
  //  attribute {
  //    name = "CountValue"
  //    type = "S"
  //  }

  # Ensure an unset TTL.
  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }
  # set some tags
  tags {
    Name  = "incrementation"
    Owner = "jprice"
  }
}
