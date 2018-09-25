#!/usr/bin/env bash

lambda_output=$(mktemp "./tmpfile.output_cmd.XXXXXXXXXXXX")
shell_output=$(mktemp "./tmpfile.output_cmd.XXXXXXXXXXXX")
input=$(mktemp "./tmpfile.input.XXXXXXXXXXXX")

echo "{}" > ${input}

aws lambda invoke \
    --invocation-type RequestResponse \
    --function-name "hello_world" \
    --region "${AWS_DEFAULT_REGION:-us-east-2}" \
    --log-type "None" \
    --payload file://"${input}" \
    ${lambda_output} > ${shell_output} 2>&1

cat ${lambda_output} | jq '.'

rm -f ${lambda_output} ${shell_output} ${input}
