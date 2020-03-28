#!/bin/sh
set -ue

# login
docker login -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD"

