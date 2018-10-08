data "archive_file" "incrementer" {
  type        = "zip"
  output_path = "${path.module}/incrementer.zip"

  source {
    content  = "${file("./la_increment_count.py")}"
    filename = "la_increment_count.py"
  }

  source {
    content  = "${file("./la_get_count.py")}"
    filename = "la_get_count.py"
  }

  source {
    content  = "${file("./la_increment_lib.py")}"
    filename = "la_increment_lib.py"
  }
}

resource "aws_lambda_function" "increment_count" {
  filename         = "${data.archive_file.incrementer.output_path}"
  function_name    = "increment_count"
  role             = "${aws_iam_role.incrementer_lambda_role.arn}"
  handler          = "la_increment_count.lambda_handler"
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

resource "aws_lambda_function" "get_count" {
  filename         = "${data.archive_file.incrementer.output_path}"
  function_name    = "get_count"
  role             = "${aws_iam_role.incrementer_lambda_role.arn}"
  handler          = "la_get_count.lambda_handler"
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
