variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "aws_default_region" {}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_default_region}"
  version    = "~> 1.30"
}

# Policy for Lambda to assume role.  Enables the other rights later
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

# Policy for incrementer lambda functions.
data "aws_iam_policy_document" "incrementer_iam_policy" {
  # Standard lambda rights for CloudWatch Events and Logs
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

  # Rights to Scan, Get, Put and Update the incrementation DDB table
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

  # Rights to list all DDB tables
  statement {
    sid    = "lambdaToDynamoDBlist"
    effect = "Allow"

    actions = [
      "dynamodb:ListTables",
    ]

    resources = ["*"]
  }
}

# Create a role for all the above
resource "aws_iam_role" "incrementer_lambda_role" {
  name = "tf.incrementer.lambda.role"

  assume_role_policy = "${data.aws_iam_policy_document.lambda_assume_role.json}"
}

# Inject all the above rights into the role
resource "aws_iam_role_policy" "incrementer_lambda_policy" {
  name = "tf.incrementer_lambda_rights"
  role = "${aws_iam_role.incrementer_lambda_role.id}"

  policy = "${data.aws_iam_policy_document.incrementer_iam_policy.json}"
}

###################################################################################################

# API Gateway assume role policy
data "aws_iam_policy_document" "apigw_assume_role" {
  statement {
    sid    = "APIGWAssumeRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "apigateway.amazonaws.com",
      ]
    }
  }
}

# Standard API Gateway -> CloudWatch Logs policy to get access logs
data "aws_iam_policy_document" "apigw_iam_policy" {
  statement {
    sid    = "APIGWWriteLogs"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
    ]

    resources = ["*"]
  }
}

# Role for apigw use
resource "aws_iam_role" "apigw_role" {
  name = "tf.apigw.role"

  assume_role_policy = "${data.aws_iam_policy_document.apigw_assume_role.json}"
}

# inject the rights from above into the apigw role
resource "aws_iam_role_policy" "apigw_policy" {
  name = "tf.apigw_cwl_rights"
  role = "${aws_iam_role.apigw_role.id}"

  policy = "${data.aws_iam_policy_document.apigw_iam_policy.json}"
}
