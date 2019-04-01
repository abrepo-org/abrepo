#!/usr/bin/env bash
#
#dev runner; execute app, bash, etc. in docker context.
#

#if # args greater than 0, set DEFAULT_CMD to input values
if [ $# -gt "0" ]; then
    DEFAULT_CMD=$1
fi

sudo docker run \
     --mount type=bind,source="$(pwd)"/app,target=/app \
     --env-file .env \
     -it abrepo_web \
     $DEFAULT_CMD
