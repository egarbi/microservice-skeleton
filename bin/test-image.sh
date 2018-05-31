#!/bin/bash

source ./bin/image-version.sh

$(${AWS_CMD} ecr get-login --no-include-email)

(

docker-compose up -d

mvn clean verify sonar:sonar

MVN_RESULT=$?
echo "MVN RESULT ${MVN_RESULT}"
if [[ -z ${MVN_RESULT} || ${MVN_RESULT} -ne 0 ]]; then
    echo -e "Incorrect mvn result ${MVN_RESULT}"
    exit 1
fi

CONTAINER=$(docker ps -q  --filter=ancestor=${IMAGE_NAME}:latest)
if [[ -z ${CONTAINER} ]]; then
    echo -e "Container ${IMAGE_NAME}:latest wasn't found."
    exit 1
fi

PORT=$(docker port ${CONTAINER} 8080/tcp|awk -F ":" '{print $2}')
if [[ -z ${PORT} ]]; then
    echo -e "Port for container ${CONTAINER} wasn't found."
    exit 1
fi

STATUS_CODE=$(wget -qO- -S --retry-connrefused --waitretry=1 --timeout=10 "http://127.0.0.1:${PORT}/health" 2>&1 \
 | grep "HTTP/" | awk '{print $2}')

echo "HTTP response: ${STATUS_CODE}"

docker-compose down -v

if [[ -z ${STATUS_CODE} || ${STATUS_CODE} -ne 200 ]]; then
    echo -e "Incorrect http status ${STATUS_CODE}"
    exit 1
fi
echo -e "Passed"

) ||  (
docker-compose logs 2>&1 | egrep -v 'Download(ing|ed):'
docker-compose down -v
echo -e "Failed"
exit 1
)
