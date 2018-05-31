#!/bin/bash

source ./bin/image-version.sh

mvn clean package -DskipTests

docker build --build-arg image_version=$IMAGE_VERSION --build-arg image_name=$IMAGE_NAME -t $IMAGE_NAME:$IMAGE_VERSION -t $IMAGE_NAME:latest .
