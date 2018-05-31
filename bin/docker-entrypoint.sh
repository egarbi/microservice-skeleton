#!/usr/bin/env bash
set -xe


PROFILE=docker
JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom -Dspring.profiles.active=$PROFILE -Xms256m -Xmx256m"

java $JAVA_OPTS -jar /app.jar

