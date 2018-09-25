#!/usr/bin/env bash

set -euo pipefail

TFVARS=terraform.tfvars

if [[ -f ${TFVARS} ]]; then
    rm -f ${TFVARS}
fi

cat > ${TFVARS} <<HEREDOC
aws_access_key = "${AWS_ACCESS_KEY_ID}"

aws_secret_key = "${AWS_SECRET_ACCESS_KEY}"

aws_default_region = "${AWS_DEFAULT_REGION}"

HEREDOC

terraform init
terraform validate
terraform plan -out ./terraform.tfplan
terraform apply -auto-approve ./terraform.tfplan
rm -f ./terraform.tfplan
