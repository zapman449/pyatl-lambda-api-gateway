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

data "aws_iam_policy_document" "hello_world_iam_policy" {
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
}

resource "aws_iam_role_policy" "hello_world_lambda_policy" {
  name = "tf.hello_world_lambda_rights"
  role = "${aws_iam_role.hello_world_lambda_role.id}"

  policy = "${data.aws_iam_policy_document.hello_world_iam_policy.json}"
}

resource "aws_iam_role" "hello_world_lambda_role" {
  name = "tf.hello_world.lambda.role"

  assume_role_policy = "${data.aws_iam_policy_document.lambda_assume_role.json}"
}
