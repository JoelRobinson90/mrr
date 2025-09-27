#!/usr/bin/env bash

docker stop "$(docker ps -a -q)"
docker rm "$(docker ps -a -q)"
docker rmi -f "$(docker images | grep "<none>" | awk "{print \$3}")"
docker system prune -a
docker volume prune