#!/bin/bash

cd infrastructure
rm -rf .terraform*
rm -f terraform.tfstate*

terraform init
terraform apply --auto-approve

terraform output -json | jq .api_url.value