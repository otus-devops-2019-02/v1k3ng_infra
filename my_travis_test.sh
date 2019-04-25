#!/bin/bash

echo "PACKER VALIDATE"
cp packer/variables.json.example packer/variables.json
packer validate -var-file=packer/variables.json packer/app.json
packer validate -var-file=packer/variables.json packer/db.json
packer validate -var-file=packer/variables.json packer/immutable.json
packer validate -var-file=packer/variables.json packer/ubuntu16.json

echo "TERRAFORM VALIDATE"
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
cp terraform/prod/terraform.tfvars.example terraform/prod/terraform.tfvars
cp terraform/stage/terraform.tfvars.example terraform/stage/terraform.tfvars
#touch terraform/stage/terraform.tfstate
#touch terraform/prod/terraform.tftfstate
cd terraform/ && terraform init
cd terraform/ && terraform validate
#cd terraform/stage/ && terraform init
cd terraform/stage/ && terraform get
cd terraform/stage/ && terraform validate
#cd terraform/prod/ && terraform init
cd terraform/prod/ && terraform get
cd terraform/prod/ && terraform validate

echo "TERRAFORM TFLINT"
cd terraform/ && tflint
cd terraform/stage/ && tflint
cd terraform/prod/ && tflint

echo "ANSIBLE-LINT"
cd ansible/playbooks && ansible-lint ./*
