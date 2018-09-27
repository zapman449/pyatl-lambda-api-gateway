#!/usr/bin/env bash

terraform plan -destroy
terraform destroy
rm -f ./terraform.tfplan
