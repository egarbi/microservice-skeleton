#!/bin/bash

source ./bin/image-version.sh

pushd ${CONF_PATH}/
terraform apply plan.out
rm plan.out
popd
