#!/bin/bash

source ./bin/image-version.sh

# Creates and set the name of ECR Repo where image will be pushed
ECR_REPO=`! ${AWS_CMD} ecr describe-repositories --repository-name ${IMAGE_NAME} --query 'repositories[].repositoryUri' --output text` && ECR_REPO=`${AWS_CMD} ecr create-repository --repository-name ${IMAGE_NAME} --query 'repository.repositoryUri' --output text`

docker tag ${IMAGE_NAME}:${IMAGE_VERSION} ${ECR_REPO}:${IMAGE_VERSION}-${TAG}
docker tag ${IMAGE_NAME}:${IMAGE_VERSION} ${ECR_REPO}:latest

$(${AWS_CMD} ecr get-login --no-include-email)
docker push ${ECR_REPO}:${IMAGE_VERSION}-${TAG}
docker push ${ECR_REPO}:latest
