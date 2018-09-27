data "archive_file" "incrementer" {
  type        = "zip"
  output_path = "${path.module}/incrementer.zip"

  source {
    content  = "${file("./la_incrementer.py")}"
    filename = "la_incrementer.py"
  }
}

resource "aws_lambda_function" "incrementer" {
  filename         = "${data.archive_file.incrementer.output_path}"
  function_name    = "incrementer"
  role             = "${aws_iam_role.incrementer_lambda_role.arn}"
  handler          = "la_incrementer.lambda_handler"
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