# The core rest_api object.
resource "aws_api_gateway_rest_api" "incrementer" {
  name        = "incrementer"
  description = "incrementer gw"
}

# a top level path off the special root_resource
resource "aws_api_gateway_resource" "incrementer_root" {
  rest_api_id = "${aws_api_gateway_rest_api.incrementer.id}"
  parent_id   = "${aws_api_gateway_rest_api.incrementer.root_resource_id}"
  path_part   = "counts"
}

# a leaf path off the previous path
resource "aws_api_gateway_resource" "incrementer_CountName" {
  rest_api_id = "${aws_api_gateway_rest_api.incrementer.id}"
  parent_id   = "${aws_api_gateway_resource.incrementer_root.id}"
  path_part   = "{CountName}"
}

# GET method on /counts/{CountName}
resource "aws_api_gateway_method" "incrementer_get" {
  rest_api_id   = "${aws_api_gateway_rest_api.incrementer.id}"
  resource_id   = "${aws_api_gateway_resource.incrementer_CountName.id}"
  http_method   = "GET"
  authorization = "NONE"
}

# 200 response for GET
resource "aws_api_gateway_method_response" "incrementer_get_200" {
  rest_api_id = "${aws_api_gateway_rest_api.incrementer.id}"
  resource_id = "${aws_api_gateway_resource.incrementer_CountName.id}"
  http_method = "${aws_api_gateway_method.incrementer_get.http_method}"
  status_code = "200"
}

# 400 response for GET
resource "aws_api_gateway_method_response" "incrementer_get_400" {
  rest_api_id = "${aws_api_gateway_rest_api.incrementer.id}"
  resource_id = "${aws_api_gateway_resource.incrementer_CountName.id}"
  http_method = "${aws_api_gateway_method.incrementer_get.http_method}"
  status_code = "400"
}

# POST method on /counts/{CountName}
resource "aws_api_gateway_method" "incrementer_post" {
  rest_api_id   = "${aws_api_gateway_rest_api.incrementer.id}"
  resource_id   = "${aws_api_gateway_resource.incrementer_CountName.id}"
  http_method   = "POST"
  authorization = "NONE"
}

# 200 response for POST
resource "aws_api_gateway_method_response" "incrementer_post_200" {
  rest_api_id = "${aws_api_gateway_rest_api.incrementer.id}"
  resource_id = "${aws_api_gateway_resource.incrementer_CountName.id}"
  http_method = "${aws_api_gateway_method.incrementer_post.http_method}"
  status_code = "200"
}

# 400 response for POST
resource "aws_api_gateway_method_response" "incrementer_post_400" {
  rest_api_id = "${aws_api_gateway_rest_api.incrementer.id}"
  resource_id = "${aws_api_gateway_resource.incrementer_CountName.id}"
  http_method = "${aws_api_gateway_method.incrementer_post.http_method}"
  status_code = "400"
}

# Links GET on /counts/{CountName} to the get_count lambda
resource "aws_api_gateway_integration" "incrementer_integration_get" {
  rest_api_id             = "${aws_api_gateway_rest_api.incrementer.id}"
  resource_id             = "${aws_api_gateway_resource.incrementer_CountName.id}"
  http_method             = "${aws_api_gateway_method.incrementer_get.http_method}"
  type                    = "AWS_PROXY"
  integration_http_method = "POST"

  uri = "${aws_lambda_function.get_count.invoke_arn}"

  passthrough_behavior = "WHEN_NO_MATCH"
}

# Links POST on /counts/{CountName} to the increment_count lambda
resource "aws_api_gateway_integration" "incrementer_integration_post" {
  rest_api_id             = "${aws_api_gateway_rest_api.incrementer.id}"
  resource_id             = "${aws_api_gateway_resource.incrementer_CountName.id}"
  http_method             = "${aws_api_gateway_method.incrementer_post.http_method}"
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = "${aws_lambda_function.increment_count.invoke_arn}"
  passthrough_behavior    = "WHEN_NO_MATCH"
}

# Permissions for GET on /counts/{CountName} to invoke get_count lambda
resource "aws_lambda_permission" "apigw_get" {
  statement_id  = "AllowAPIGatewayGet"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.get_count.arn}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.incrementer.execution_arn}/*/*/*"
}

# Permissions for POST on /counts/{CountName} to invoke increment_count lambda
resource "aws_lambda_permission" "apigw_increment" {
  statement_id  = "AllowAPIGatewayIncrement"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.increment_count.arn}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.incrementer.execution_arn}/*/*/*"
}

# Enable access logs for your api gateway
resource "aws_cloudwatch_log_group" "incrementer_lg" {
  name              = "/apigw/incrementer_logs"
  retention_in_days = 1

  tags {
    Application = "incrementer"
  }
}

# does an AWS API Gateway Deployment on all the above.  API Gateway has a Deploy step to make things
# active, and this triggers that.
# NOTE: this plays into AWS API Gateway Stages as well, which allow you to do some level of "deploy v1.2 to
# dev", v1.1 to staging, v1.0.1 to prod.  This is not implemented here.
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

# AWS API Gateway allows you to set request counts (quotas), and request/second counts (throttles)
# Super useful, but I'm not using them here.  Below is a half baked example of how it works
//resource "aws_api_gateway_usage_plan" "incrementer_plan" {
//  name = "incrementer_usage_plan"
//
//  api_stages {
//    api_id = "${aws_api_gateway_rest_api.incrementer.id}"
//    stage  = "${aws_api_gateway_deployment.incrementer.stage_name}"
//  }
//
//  quota_settings {
//    limit  = 100
//    offset = 0
//    period = "DAY"
//  }
//
//  throttle_settings {
//    burst_limit = 5
//    rate_limit  = 10
//  }
//}

# TF magic to coerce AWS API Gateway for the whole account to have a cloudwatch logs role.
resource "aws_api_gateway_account" "incrementer" {
  cloudwatch_role_arn = "${aws_iam_role.apigw_role.arn}"
}

# Output the base URL since that's kinda required
output "incrementer_base_url" {
  value = "${aws_api_gateway_deployment.incrementer.invoke_url}"
}
