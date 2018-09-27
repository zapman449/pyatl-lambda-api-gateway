variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "aws_default_region" {}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_default_region}"
  version    = "~> 1.30"
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    sid    = "instanceAssumeRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "incrementer_iam_policy" {
    statement {
    sid    = "lambdaWriteLogs"
    effect = "Allow"

    actions = [
      "events:DescribeRule",
      "events:PutEvents",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "lambdaToDynamoDB"
    effect = "Allow"

    actions = [
      "dynamodb:Scan",
      "dynamodb:Get*",
      "dynamodb:Put*",
      "dynamodb:UpdateItem",
    ]

    resources = [
      "${aws_dynamodb_table.incrementation.arn}",
      "${aws_dynamodb_table.incrementation.arn}/*",
    ]
  }

  statement {
    sid    = "lambdaToDynamoDBlist"
    effect = "Allow"

    actions = [
      "dynamodb:ListTables",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role" "incrementer_lambda_role" {
  name = "tf.incrementer.lambda.role"

  assume_role_policy = "${data.aws_iam_policy_document.lambda_assume_role.json}"
}

resource "aws_iam_role_policy" "incrementer_lambda_policy" {
  name = "tf.incrementer_lambda_rights"
  role = "${aws_iam_role.incrementer_lambda_role.id}"

  policy = "${data.aws_iam_policy_document.incrementer_iam_policy.json}"
}
