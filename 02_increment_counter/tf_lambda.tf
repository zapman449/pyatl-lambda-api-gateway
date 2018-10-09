# Terraform can create the zip file for Lambda.  This works great if you just need Boto3 and standard lib
# stuff.  If you're getting more complicated, you probably want to build the zip file outside of Terraform
# and tell Terraform to leverage it.
# I also can get away with a single zip file for both lambdas.  There's a point where that's not wise or
# practical any more.
data "archive_file" "incrementer" {
  type        = "zip"
  output_path = "${path.module}/incrementer.zip"

  source {
    content  = "${file("./python/increment_count.py")}"
    filename = "increment_count.py"
  }

  source {
    content  = "${file("./python/get_count.py")}"
    filename = "get_count.py"
  }

  source {
    content  = "${file("./python/increment_lib.py")}"
    filename = "increment_lib.py"
  }
}

# The POST lambda function
resource "aws_lambda_function" "increment_count" {
  filename         = "${data.archive_file.incrementer.output_path}"
  function_name    = "increment_count"
  role             = "${aws_iam_role.incrementer_lambda_role.arn}"
  handler          = "increment_count.lambda_handler"
  runtime          = "python3.6"
  source_code_hash = "${base64sha256(file("${data.archive_file.incrementer.output_path}"))}"
  timeout          = 10
  publish          = true

  environment {
    variables = {
      INCREMENTATION_TABLE_NAME = "${aws_dynamodb_table.incrementation.name}"
    }
  }
}

# The GET lambda function
resource "aws_lambda_function" "get_count" {
  filename         = "${data.archive_file.incrementer.output_path}"
  function_name    = "get_count"
  role             = "${aws_iam_role.incrementer_lambda_role.arn}"
  handler          = "get_count.lambda_handler"
  runtime          = "python3.6"
  source_code_hash = "${base64sha256(file("${data.archive_file.incrementer.output_path}"))}"
  timeout          = 10
  publish          = true

  environment {
    variables = {
      INCREMENTATION_TABLE_NAME = "${aws_dynamodb_table.incrementation.name}"
    }
  }
}
