resource "aws_api_gateway_rest_api" "incrementer" {
  name        = "incrementer"
  description = "incrementer gw"
}

resource "aws_api_gateway_resource" "incrementer_root" {
  rest_api_id = "${aws_api_gateway_rest_api.incrementer.id}"
  parent_id   = "${aws_api_gateway_rest_api.incrementer.root_resource_id}"
  path_part   = "counts"
}

resource "aws_api_gateway_resource" "incrementer_CountName" {
  rest_api_id = "${aws_api_gateway_rest_api.incrementer.id}"
  parent_id   = "${aws_api_gateway_resource.incrementer_root.id}"
  path_part   = "{CountName}"
}

resource "aws_api_gateway_method" "incrementer_get" {
  rest_api_id   = "${aws_api_gateway_rest_api.incrementer.id}"
  resource_id   = "${aws_api_gateway_resource.incrementer_CountName.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "incrementer_get_200" {
  rest_api_id = "${aws_api_gateway_rest_api.incrementer.id}"
  resource_id = "${aws_api_gateway_resource.incrementer_CountName.id}"
  http_method = "${aws_api_gateway_method.incrementer_get.http_method}"
  status_code = "200"
}

resource "aws_api_gateway_method_response" "incrementer_get_400" {
  rest_api_id = "${aws_api_gateway_rest_api.incrementer.id}"
  resource_id = "${aws_api_gateway_resource.incrementer_CountName.id}"
  http_method = "${aws_api_gateway_method.incrementer_get.http_method}"
  status_code = "400"
}

resource "aws_api_gateway_method" "incrementer_post" {
  rest_api_id   = "${aws_api_gateway_rest_api.incrementer.id}"
  resource_id   = "${aws_api_gateway_resource.incrementer_CountName.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "incrementer_post_200" {
  rest_api_id = "${aws_api_gateway_rest_api.incrementer.id}"
  resource_id = "${aws_api_gateway_resource.incrementer_CountName.id}"
  http_method = "${aws_api_gateway_method.incrementer_post.http_method}"
  status_code = "200"
}

resource "aws_api_gateway_method_response" "incrementer_post_400" {
  rest_api_id = "${aws_api_gateway_rest_api.incrementer.id}"
  resource_id = "${aws_api_gateway_resource.incrementer_CountName.id}"
  http_method = "${aws_api_gateway_method.incrementer_post.http_method}"
  status_code = "400"
}

resource "aws_api_gateway_integration" "incrementer_integration_get" {
  rest_api_id             = "${aws_api_gateway_rest_api.incrementer.id}"
  resource_id             = "${aws_api_gateway_resource.incrementer_CountName.id}"
  http_method             = "${aws_api_gateway_method.incrementer_get.http_method}"
  type                    = "AWS_PROXY"
  integration_http_method = "POST"

  uri = "${aws_lambda_function.get_count.invoke_arn}"

  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_api_gateway_integration" "incrementer_integration_post" {
  rest_api_id             = "${aws_api_gateway_rest_api.incrementer.id}"
  resource_id             = "${aws_api_gateway_resource.incrementer_CountName.id}"
  http_method             = "${aws_api_gateway_method.incrementer_post.http_method}"
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = "${aws_lambda_function.increment_count.invoke_arn}"
  passthrough_behavior    = "WHEN_NO_MATCH"
}

resource "aws_lambda_permission" "apigw_get" {
  statement_id  = "AllowAPIGatewayGet"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.get_count.arn}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.incrementer.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "apigw_increment" {
  statement_id  = "AllowAPIGatewayIncrement"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.increment_count.arn}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.incrementer.execution_arn}/*/*/*"
}

resource "aws_cloudwatch_log_group" "incrementer_lg" {
  name              = "/jprice/incrementer_logs"
  retention_in_days = 1

  tags {
    Application = "incrementer"
  }
}

resource "aws_api_gateway_deployment" "incrementer" {
  depends_on = [
    "aws_api_gateway_resource.incrementer_root",
    "aws_api_gateway_resource.incrementer_CountName",
    "aws_api_gateway_method.incrementer_get",
    "aws_api_gateway_method.incrementer_post",
    "aws_api_gateway_integration.incrementer_integration_get",
    "aws_api_gateway_integration.incrementer_integration_post",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.incrementer.id}"
  stage_name  = "prod"
}

resource "aws_api_gateway_stage" "incrementer" {
  stage_name    = "dev-logs"
  rest_api_id   = "${aws_api_gateway_rest_api.incrementer.id}"
  deployment_id = "${aws_api_gateway_deployment.incrementer.id}"

  access_log_settings {
    destination_arn = "${aws_cloudwatch_log_group.incrementer_lg.arn}"
    format          = "$context.identity.sourceIp $context.identity.caller $context.identity.user [$context.requestTime] \"$context.httpMethod $context.resourcePath $context.protocol\" $context.status $context.responseLength $context.requestId"
  }
}

resource "aws_api_gateway_usage_plan" "incrementer_plan" {
  name = "incrementer_usage_plan"

  api_stages {
    api_id = "${aws_api_gateway_rest_api.incrementer.id}"
    stage  = "${aws_api_gateway_stage.incrementer.stage_name}"
  }

  api_stages {
    api_id = "${aws_api_gateway_rest_api.incrementer.id}"
    stage  = "${aws_api_gateway_deployment.incrementer.stage_name}"
  }

  quota_settings {
    limit  = 100
    offset = 0
    period = "DAY"
  }

  throttle_settings {
    burst_limit = 5
    rate_limit  = 10
  }
}

resource "aws_api_gateway_account" "incrementer" {
  cloudwatch_role_arn = "${aws_iam_role.apigw_role.arn}"
}

output "incrementer_base_url" {
  value = "${aws_api_gateway_deployment.incrementer.invoke_url}"
}

output "incrementer_dev_stage_url" {
  value = "${aws_api_gateway_stage.incrementer.invoke_url}"
}
