# My First Lambda

## Incrementer

### la_increment_count.py
Given a `CountName` increment it.

Leverages DynamoDB to store the counts.

### la_get_count.py
Given a `CountName` retrieve current count

## Steps to deploy

1. Install Terraform
2. Get the shell variables AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, and AWS_DEFAULT_REGION into
   your shell environment
3. run `deployer.sh`.  This will:
    1. Validate the terraform code
    2. Plan and apply the terraform code to
        * make the 2 lambdas
        * create the DynamoDB table
        * setup the IAM work
    3. Verify that any log-groups have a 1 day retention period (In theory, terraform should do this
       but Terraform creates the lambda, and lambda creates the log group, so it's one removed)
    4. delete the created zip file
4. run `./runner.sh SOMETHING` and the SOMETHING counter will get incremented

## My First API Gateway

1. Run `./link_03.sh`.  This will symlink in the tf_api_gw.tf file
2. re-run `./deployer.sh`.  This will deploy all the AWS API Gateway stuff.
3. Take the `incrementer_base_url` into your copy buffer
4. run `curl -w "\n" -X POST ${INCREMENTER_BASE_URL}/counts/from_curl`
5. Keep running and watch the count increment
6. run `curl -w "\n" -X GET ${INCREMENTER_BASE_URL}/counts/from_curl`
7. Keep running and watch the count stay the same
