#!/bin/bash
set -xe

PROJECT=$(mvn -q -Dexec.executable="echo" -Dexec.args='${project.artifactId} ${project.version}' \
--non-recursive org.codehaus.mojo:exec-maven-plugin:1.5.0:exec)

IMAGE_NAME=$(echo "$PROJECT" | awk '{print $1}')
IMAGE_VERSION=$(echo "$PROJECT" | awk '{print $2}')
TAG=$(git rev-parse --short HEAD)

REGION='eu-west-1'
AWS_CMD="aws"
export AWS_DEFAULT_REGION="$REGION"

CONF_PATH="./terraform"
