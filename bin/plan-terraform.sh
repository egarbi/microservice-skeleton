#!/bin/bash

source ./bin/image-version.sh

ENV=${1}
BUCKET=${IMAGE_NAME}-states
INIT_FILE=${CONF_PATH}/init.tf
LOCK_TABLE="${IMAGE_NAME}-infra-locks"

get_last_priority() 
{
  ALB=$(${AWS_CMD} elbv2 describe-load-balancers --query 'LoadBalancers[*].LoadBalancerArn' | awk -F\" "/talk-${ENV}/ {print \$2}")
  LISTENER=$(${AWS_CMD} elbv2 describe-listeners --load-balancer-arn $ALB --query 'Listeners[].ListenerArn' | awk -F\" '{print $2}')
  ar=($(${AWS_CMD} elbv2 describe-rules --listener-arn $LISTENER --query='Rules[].Priority' --output text))
  IFS=$'\n'
  CURRENT_PRIORITY=$(echo "${ar[*]}" | sort -nr | head -n1)
  PRIORITY=$(expr $CURRENT_PRIORITY + 10)
}

if [[ "${ENV}" != testing ]] && [[ "${ENV}" != prod ]]; then
  echo "Usage: $0 environment"
  exit 1
fi

# S3 Bucket where state file will be saved
${AWS_CMD} s3 ls s3://${BUCKET} &> /dev/null || ${AWS_CMD} s3 mb s3://${BUCKET}
${AWS_CMD} s3api put-bucket-versioning --bucket ${BUCKET} --versioning-configuration Status=Enabled

# State locks are implemented using DynamoDB tables
${AWS_CMD} dynamodb describe-table --table-name ${LOCK_TABLE} &> /dev/null || ${AWS_CMD} dynamodb create-table --table-name ${LOCK_TABLE} --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema KeyType=HASH,AttributeName=LockID --provisioned-throughput WriteCapacityUnits=1,ReadCapacityUnits=1

# Build a setup file based on project
cat <<EOF > ${INIT_FILE}
terraform {
  backend "s3" {
    bucket = "${BUCKET}"
    key    = "terraform"
    region = "${REGION}"
    dynamodb_table = "${LOCK_TABLE}"
  }
}
EOF

pushd ${CONF_PATH}/
terraform init -upgrade=true
terraform workspace select ${ENV} || terraform workspace new ${ENV}
PRIORITY=$(terraform show | awk '/priority/ {print $3}')
if [ -z "${PRIORITY}" ]; then
  get_last_priority
fi
terraform plan -out plan.out -var "name=${IMAGE_NAME}" -var "image_version=${IMAGE_VERSION}" -var "tag=${TAG}" -var "priority=${PRIORITY}" 
popd
