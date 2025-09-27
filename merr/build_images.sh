#!/usr/bin/env bash
set -e

INITIAL_WORKING_DIRECTORY=$(pwd)
DOCKER_COMPOSE_COMMAND=$("$INITIAL_WORKING_DIRECTORY"/bin/direnv/which_docker_compose)

image_name=$("$INITIAL_WORKING_DIRECTORY"/bin/direnv/docker_image_tag)

stop_dockers_command="make docker.stop"
build_command="docker build . -f ./Dockerfile.base -t ${image_name}"
compose_build_command="IMAGE_NAME=${image_name} $DOCKER_COMPOSE_COMMAND -f ./docker-compose.yml build"

mkdir -p ./tmp/db

if [[ $1 == "FORCE" ]]; then
  # FORCE BUILD
  eval "$stop_dockers_command"
  echo "FORCE Building base image ${image_name}"

  echo "$build_command"
  eval "$build_command"

  echo "$compose_build_command"
  eval "$compose_build_command"
else
  echo "Smart docker image building of ${image_name}"
  if [[ -n "$(docker images -q "${image_name}")" ]]; then
    echo "Base image ${image_name} found."
  else

    eval "$stop_dockers_command"
    echo "Building base image ${image_name}"
    echo "$build_command"
    eval "$build_command"

    echo "$compose_build_command"
    eval "$compose_build_command"
  fi
fi

