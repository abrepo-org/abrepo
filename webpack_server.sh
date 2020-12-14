#!/usr/bin/env bash

# needs to run in same container as the docker-compose stack
# this runtime takes over from compose and allows *much* faster
# compilation for hot reloads

DEFAULT_CMD=./bin/webpack-dev-server
sudo docker exec -it abrepo_web_1 $DEFAULT_CMD
