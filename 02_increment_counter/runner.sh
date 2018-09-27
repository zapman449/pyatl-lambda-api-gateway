#!/usr/bin/env bash

lambda_output=$(mktemp "./tmpfile.lambda_output.XXXXXXXXXXXX")
shell_output=$(mktemp "./tmpfile.shell_output.XXXXXXXXXXXX")
lambda_input=$(mktemp "./tmpfile.lambda_input.XXXXXXXXXXXX")

DEBUG=${DEBUG:-FALSE}
AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-us-east-2}

if [[ "${DEBUG}" == "TRUE" ]]; then
    LOG_TYPE="Tail"
else
    LOG_TYPE="None"
fi

if [[ -z "$1" ]]; then
    echo "ERROR: Must supply count name"
    exit 1
fi
CountName=$1

echo "{
  \"CountName\": \"${CountName}\"
}" > ${lambda_input}

aws lambda invoke \
    --invocation-type RequestResponse \
    --function-name "incrementer" \
    --region "${AWS_DEFAULT_REGION}" \
    --log-type "${LOG_TYPE}" \
    --payload file://"${lambda_input}" \
    ${lambda_output} 1> ${shell_output} 2>&1

if [[ "${DEBUG}" == "TRUE" ]]; then
    echo "----> Lambda Output:"
fi
cat ${lambda_output} | jq '.'

if [[ "${DEBUG}" == "TRUE" ]]; then
    echo "----> Shell Output:"
    cat ${shell_output}
    echo "----> log decode"
    jq -r ".LogResult" ${shell_output} | base64 -d
fi

rm -f ${lambda_output} ${shell_output} ${lambda_input}
