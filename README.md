# Lambda and Python for PyATL, Oct 2018

## Purpose:

Build a fully functioning Lambda + AWS API Gateway integration, from end to end.  

Exposes one endpoint: `/counts/<CountName>` and two methods on that endpoint: `GET` and `POST`.
Future work could include implementing `DELETE` as well (exercise for the reader).

## Directory map:

* `00_pre_req` - Terraform for the prebuilt IAM rights for hello_world lambda
* `01_hello_world` - Python code for hello_world lambda function
* `02_increment_counter` - Python code to increment a counter in dynamodb, and tf code to deploy
* `03_api_gateway` - Final piece of terraform, does API GW.  Will be symlinked into the 02 directory.
* `04_aws_serverless` - TODO

## URI Map:

`/counts/<CountName>`
* GET -> Retrieve current count for `<CountName>`
* POST -> increment current count, retrieve new count for `<CountName>`

## API Gateway with TF doc:
https://www.terraform.io/docs/providers/aws/guides/serverless-with-aws-lambda-and-api-gateway.html

